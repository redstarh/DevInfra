#!/usr/bin/env python3
"""Backlog.md 원장을 읽어 감사 패널 HTML을 만든다. 원장에는 쓰지 않는다.

usage: audit_panel.py <repo> [--out PATH] [--round N]

출력 기본값은 <repo>/.harness/audit-board.html — 추적 밖 경로라 커밋 위험이 없다.
색은 dataviz skill 의 검증된 값이다: 4단계는 ordinal 단일 hue(라이트·다크 전 항목 PASS),
어긋남·의존은 status 팔레트 + 아이콘 + 라벨(색 단독으로 뜻을 나르지 않는다).
"""
import glob
import html
import io
import os
import re
import subprocess
import sys
from datetime import datetime

# --- dataviz: ordinal 램프 (blue, 검증 완료) ---
RAMP_LIGHT = ["#86b6ef", "#5598e7", "#2a78d6", "#1c5cab"]
RAMP_DARK = ["#6da7ec", "#3987e5", "#256abf", "#184f95"]
# --- dataviz: status 팔레트 (고정, 테마 무관) ---
# 아이콘은 **텍스트 글리프만** 쓴다 — 이모지는 CSS color 를 무시하고 고유색으로 렌더돼
# 지정한 status 색이 조용히 사라진다(실측: ⏳ 가 warning 색을 안 받았다).
STATUS = {
    "good": ("#0ca30c", "✓"),
    "warning": ("#fab219", "○"),
    "serious": ("#ec835a", "▶"),
    "critical": ("#d03b3b", "✕"),
}
DEFAULT_STATUSES = ["To Do", "In Progress", "Awaiting Decision", "Done"]


def frontmatter(text):
    """--- 로 감싼 앞머리를 {키: 값 또는 리스트} 로 만든다. 없으면 {}."""
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        return {}
    out, key = {}, None
    for line in m.group(1).split("\n"):
        item = re.match(r"^\s+-\s+(.*)$", line)
        if item and key:
            out.setdefault(key, [])
            if isinstance(out[key], list):
                out[key].append(item.group(1).strip().strip("'\""))
            continue
        kv = re.match(r"^([A-Za-z_]+):\s*(.*)$", line)
        if kv:
            key, val = kv.group(1), kv.group(2).strip()
            # 값이 비면 리스트로 열어 둔다 — 다음 줄의 "  - x" 를 받을 자리다.
            # 문자열로 두면 뒤따르는 항목이 조용히 버려진다(실측 버그: labels 가 항상 빈 값이 됐다).
            out[key] = [] if val in ("", "[]") else val.strip("'\"")
    return out


def load(repo):
    tasks = {}
    for path in sorted(glob.glob(os.path.join(repo, "backlog", "tasks", "*.md"))):
        try:
            fm = frontmatter(io.open(path, encoding="utf-8").read())
        except OSError:
            continue
        tid = fm.get("id")
        if not tid:
            continue
        labels = fm.get("labels") or []
        tasks[tid] = {
            "status": fm.get("status") or "",
            "title": fm.get("title") or "",
            # 라벨은 labels 필드에서만 읽는다 — 본문 문자열을 세면 부풀려진다(실측 함정)
            "labels": labels if isinstance(labels, list) else [],
            "deps": [d for d in (fm.get("dependencies") or []) if isinstance(d, str)],
            "priority": fm.get("priority") or "",
            "updated": fm.get("updated_date") or "",
        }
    return tasks


def statuses_of(repo):
    cfg = os.path.join(repo, "backlog", "config.yml")
    try:
        m = re.search(r"^statuses:\s*\[(.*)\]", io.open(cfg, encoding="utf-8").read(), re.M)
        if m:
            got = [s.strip().strip("'\"") for s in m.group(1).split(",") if s.strip()]
            if got:
                return got
    except OSError:
        pass
    return DEFAULT_STATUSES


def sort_key(tid):
    m = re.search(r"(\d+)$", tid)
    return int(m.group(1)) if m else 0


def is_active(status, order):
    """'실제로 손을 대고 있는' 상태인가. 첫 상태(미착수)·끝 상태(완료)·사람 결정 대기는 제외한다.
    상태 이름을 하드코딩하지 않으려고 config 의 순서와 낱말로 판정한다 — 결정 대기 상태에
    선행 미충족이 남아 있는 것은 역전이 아니라 정상이다."""
    if not order or status in (order[0], order[-1]):
        return False
    return not re.search(r"await|decision|hold|block|대기|결정|보류", status, re.I)


def analyse(tasks, order):
    """어긋남 3종을 계산한다. 판정 근거는 dependencies 와 status 뿐이다."""
    done = {t for t, v in tasks.items() if order and v["status"] == order[-1]}
    todo = order[0] if order else "To Do"
    ready, waiting, reversed_ = [], [], []
    for tid, v in tasks.items():
        if not v["deps"]:
            continue
        unmet = [d for d in v["deps"] if d not in done]
        if v["status"] == todo and not unmet:
            ready.append(tid)                       # 착수 가능한데 안 함
        elif not unmet:
            continue                                # 선행이 다 풀렸고 이미 진행/완료 — 정상
        elif is_active(v["status"], order):
            reversed_.append((tid, unmet))          # 선행을 건너뛰고 착수
        else:
            waiting.append((tid, unmet))            # 정상 대기
    caps = sorted(
        (t for t, v in tasks.items()
         if "caps-req" in v["labels"] and v["status"] != (order[-1] if order else "Done")),
        key=sort_key,
    )
    return {
        "ready": sorted(ready, key=sort_key),
        "waiting": sorted(waiting, key=lambda x: sort_key(x[0])),
        "reversed": sorted(reversed_, key=lambda x: sort_key(x[0])),
        "caps": caps,
        "caps_high": [t for t in caps if tasks[t]["priority"] == "high"],
    }


def head_of(repo):
    try:
        out = subprocess.run(
            ["git", "-C", repo, "log", "-1", "--format=%h %ad %s", "--date=format:%m-%d %H:%M"],
            capture_output=True, text=True, timeout=10,
        )
        return out.stdout.strip() or "(git 정보 없음)"
    except (OSError, subprocess.SubprocessError):
        return "(git 정보 없음)"


def tile(label, value, role=None):
    color = f"var(--st-{role})" if role else "var(--text-primary)"
    icon = f'<span class="ic">{STATUS[role][1]}</span> ' if role else ""
    return (f'<div class="tile"><div class="tv" style="color:{color}">{icon}{value}</div>'
            f'<div class="tl">{html.escape(label)}</div></div>')


def rows(items, role, note):
    if not items:
        return ""
    icon = STATUS[role][1]
    out = []
    for it in items:
        tid, extra = (it, "") if isinstance(it, str) else (it[0], " · 미충족 " + ", ".join(it[1]))
        out.append(
            f'<tr><td class="badge"><span style="color:var(--st-{role})">{icon}</span> '
            f'{html.escape(note)}</td><td class="mono">{html.escape(tid)}</td>'
            f'<td class="sub">{html.escape(extra.strip(" ·"))}</td></tr>'
        )
    return "".join(out)


def render(repo, tasks, a, order, rnd):
    now = datetime.now().astimezone()
    counts = [(s, sum(1 for v in tasks.values() if v["status"] == s)) for s in order]
    total = len(tasks) or 1
    findings = len(a["ready"]) + len(a["reversed"])

    segs, legend = [], []
    for i, (name, n) in enumerate(counts):
        li, dk = RAMP_LIGHT[i % 4], RAMP_DARK[i % 4]
        if n:
            segs.append(
                f'<span class="seg" style="--l:{li};--d:{dk};flex:{n}" '
                f'title="{html.escape(name)}: {n}건 ({n*100//total}%)"></span>'
            )
        legend.append(
            f'<span class="lg"><i style="--l:{li};--d:{dk}"></i>{html.escape(name)}'
            f'<b>{n}</b></span>'
        )

    body = [
        f'<h1>{html.escape(os.path.basename(os.path.abspath(repo)))} <span class="sub">작업 감사 패널</span></h1>',
        f'<p class="sub">감사 {rnd} · {now:%Y-%m-%d %H:%M:%S %Z} · HEAD {html.escape(head_of(repo))}</p>',
        '<div class="tiles">',
        tile("어긋남", findings, "critical" if findings else "good"),
        tile("caps-req 미이행", len(a["caps"]), "serious" if a["caps"] else "good"),
        tile("착수 가능·미착수", len(a["ready"]), "serious" if a["ready"] else "good"),
        tile("전체 태스크", len(tasks)),
        "</div>",
        f'<h2>상태 분포 <span class="sub">{len(tasks)}건</span></h2>',
        f'<div class="bar">{"".join(segs) or "<span class=sub>태스크 없음</span>"}</div>',
        f'<div class="legend">{"".join(legend)}</div>',
    ]

    fr = (rows(a["reversed"], "critical", "순서 역전")
          + rows(a["ready"], "serious", "착수 가능·미착수")
          + rows(a["waiting"], "warning", "선행 대기(정상)"))
    body.append("<h2>의존 상태</h2>")
    body.append(
        f'<table>{fr}</table>' if fr else
        f'<p class="ok"><span style="color:var(--st-good)">{STATUS["good"][1]}</span> '
        "의존을 가진 태스크가 없거나 전부 정상이다</p>"
    )

    body.append('<h2>전체 태스크 <span class="sub">표 보기</span></h2><table class="all">'
                "<tr><th>ID</th><th>상태</th><th>제목</th><th>선행</th></tr>")
    for tid in sorted(tasks, key=sort_key):
        v = tasks[tid]
        hi = ' <span class="hi">HIGH</span>' if v["priority"] == "high" else ""
        cp = ' <span class="cp">caps-req</span>' if "caps-req" in v["labels"] else ""
        body.append(
            f'<tr><td class="mono">{html.escape(tid)}</td><td>{html.escape(v["status"])}</td>'
            f'<td>{html.escape(v["title"])}{hi}{cp}</td>'
            f'<td class="mono sub">{html.escape(", ".join(v["deps"]))}</td></tr>'
        )
    body.append("</table>")
    body.append('<p class="sub">⚠️ 원장의 created_date·updated_date 는 UTC 로 적힌다 — '
                "현지 시각과 어긋나므로 착수 지연을 시각차로 논할 때 보정한다. "
                "이 패널의 시각은 생성 시점의 현지 시각이다.</p>")

    st = "".join(f"--st-{k}:{v[0]};" for k, v in STATUS.items())
    return f"""<!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="120">
<title>{html.escape(os.path.basename(os.path.abspath(repo)))} 감사 패널</title><style>
:root{{color-scheme:light;--surface:#fcfcfb;--plane:#f9f9f7;--text-primary:#0b0b0b;
--text-secondary:#52514e;--muted:#898781;--rule:#e1e0d9;--ring:rgba(11,11,11,.10);{st}}}
@media (prefers-color-scheme:dark){{:root:where(:not([data-theme=light])){{color-scheme:dark;
--surface:#1a1a19;--plane:#0d0d0d;--text-primary:#fff;--text-secondary:#c3c2b7;
--muted:#898781;--rule:#2c2c2a;--ring:rgba(255,255,255,.10)}}}}
:root[data-theme=dark]{{color-scheme:dark;--surface:#1a1a19;--plane:#0d0d0d;
--text-primary:#fff;--text-secondary:#c3c2b7;--rule:#2c2c2a;--ring:rgba(255,255,255,.10)}}
*{{box-sizing:border-box}}
body{{margin:0;padding:28px;background:var(--plane);color:var(--text-primary);
font:15px/1.55 system-ui,-apple-system,"Segoe UI",sans-serif}}
h1{{font-size:20px;margin:0 0 2px}}h2{{font-size:14px;margin:26px 0 8px;
color:var(--text-secondary);font-weight:600}}
.sub{{color:var(--muted);font-size:13px;font-weight:400}}
.tiles{{display:flex;gap:10px;flex-wrap:wrap;margin-top:16px}}
.tile{{flex:1 1 150px;background:var(--surface);border:1px solid var(--ring);
border-radius:10px;padding:14px 16px}}
.tv{{font-size:26px;font-weight:650;line-height:1.1}}
.tl{{color:var(--text-secondary);font-size:12px;margin-top:3px}}
.ic{{font-size:18px}}
.bar{{display:flex;gap:2px;height:26px;background:var(--surface);
border:1px solid var(--ring);border-radius:6px;overflow:hidden;padding:2px}}
.seg{{background:var(--l);border-radius:4px;min-width:6px}}
@media (prefers-color-scheme:dark){{.seg{{background:var(--d)}}}}
.legend{{display:flex;gap:16px;flex-wrap:wrap;margin-top:8px;font-size:13px;
color:var(--text-secondary)}}
.lg i{{display:inline-block;width:9px;height:9px;border-radius:2px;background:var(--l);
margin-right:6px}}
@media (prefers-color-scheme:dark){{.lg i{{background:var(--d)}}}}
.lg b{{margin-left:6px;color:var(--text-primary);font-variant-numeric:tabular-nums}}
table{{width:100%;border-collapse:collapse;background:var(--surface);
border:1px solid var(--ring);border-radius:8px;overflow:hidden;font-size:13px}}
th{{text-align:left;color:var(--muted);font-weight:600;font-size:12px}}
th,td{{padding:7px 12px;border-bottom:1px solid var(--rule);vertical-align:top}}
tr:last-child td{{border-bottom:0}}
.mono{{font-variant-numeric:tabular-nums;white-space:nowrap}}
.badge{{white-space:nowrap;font-weight:600}}
.hi{{color:var(--st-critical);font-size:11px;font-weight:700}}
.cp{{color:var(--muted);font-size:11px}}
.ok{{background:var(--surface);border:1px solid var(--ring);border-radius:8px;
padding:12px 14px;margin:0}}
</style></head><body>{"".join(body)}</body></html>"""


def main(argv):
    if len(argv) < 2:
        print((__doc__ or "").strip(), file=sys.stderr)
        return 2
    repo = os.path.abspath(argv[1])
    out, rnd = os.path.join(repo, ".harness", "audit-board.html"), "-"
    for i, a in enumerate(argv):
        if a == "--out" and i + 1 < len(argv):
            out = os.path.abspath(argv[i + 1])
        if a == "--round" and i + 1 < len(argv):
            rnd = f"{argv[i + 1]}회차"
    if not os.path.isdir(os.path.join(repo, "backlog", "tasks")):
        print(f"error: {repo}/backlog/tasks 가 없다 — Backlog.md 리포가 맞는지 본다", file=sys.stderr)
        return 1
    tasks = load(repo)
    order = statuses_of(repo)
    a = analyse(tasks, order)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    io.open(out, "w", encoding="utf-8").write(render(repo, tasks, a, order, rnd))
    print(f"wrote {out}")
    print(f"tasks={len(tasks)} 어긋남={len(a['ready']) + len(a['reversed'])} "
          f"caps_req_미이행={len(a['caps'])} high={a['caps_high']}")
    print(f"ready={a['ready']} reversed={[t for t, _ in a['reversed']]} "
          f"waiting={[t for t, _ in a['waiting']]}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
