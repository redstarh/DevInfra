#!/usr/bin/env python3
"""감사 기계부 — OS 크론에서 정시에 돈다. LLM 없이 A·B·B'만 계산한다.

usage: audit_cycle.py <repo> [--serve-port 6421]

C·D(주장 대 증거 / 방식 대체)는 사람 판단이라 이 스크립트가 하지 않는다 — 세션이 한다.
이 스크립트가 보장하는 것은 **패널·생존 신호·발동 이력이 절대 낡지 않는 것**이다.
하네스 내장 크론은 REPL 이 idle 일 때만 발동하므로 정시성을 보장할 수 없다(실측: 슬롯 누락).
그래서 기계부를 OS 크론으로 내렸다.

⚠️ 출력은 <repo>/.harness/ 안에만 쓴다. 원장·코드·문서를 건드리지 않는다.
⚠️ 값을 문자열로 파싱하지 않는다 — audit_panel 을 import 해서 같은 함수를 쓴다.
   (크론은 로케일이 최소라 한글 패턴 sed/grep 이 깨질 수 있다.)
"""
import io
import os
import subprocess
import sys
from datetime import datetime

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
# 같은 디렉터리의 형제 모듈 — 위 sys.path 삽입으로 런타임에 해결된다.
# 정적 분석기는 그 삽입을 못 보고 미해결로 표시하므로 무시 지시를 붙인다.
import audit_panel as ap  # noqa: E402  # type: ignore[import-not-found]


def next_round(log_path):
    """발동 이력의 회차 행 수 + 1. 로그가 없으면 1."""
    try:
        lines = io.open(log_path, encoding="utf-8").read().splitlines()
    except OSError:
        return 1
    return sum(1 for ln in lines if "회차=" in ln) + 1


def ensure_server(harness_dir, port):
    """패널 정적 서버가 죽어 있으면 되살린다. 이미 살아 있으면 아무것도 하지 않는다."""
    try:
        probe = subprocess.run(
            ["/usr/sbin/lsof", "-nP", f"-iTCP:{port}", "-sTCP:LISTEN"],
            capture_output=True, text=True, timeout=10,
        )
        if probe.stdout.strip():
            return "이미 실행 중"
    except (OSError, subprocess.SubprocessError):
        return "확인 실패"
    try:
        with open(os.devnull, "wb") as null:
            subprocess.Popen(
                [sys.executable, "-m", "http.server", str(port), "--bind", "127.0.0.1"],
                cwd=harness_dir, stdout=null, stderr=null,
                start_new_session=True,
            )
        return f"재기동({port})"
    except (OSError, subprocess.SubprocessError) as exc:
        return f"재기동 실패: {exc}"


def main(argv):
    if len(argv) < 2:
        print((__doc__ or "").strip(), file=sys.stderr)
        return 2
    repo = os.path.abspath(argv[1])
    port = None
    if "--serve-port" in argv:
        i = argv.index("--serve-port")
        if i + 1 < len(argv):
            port = argv[i + 1]

    harness = os.path.join(repo, ".harness")
    log = os.path.join(harness, "audit-fire-log.txt")
    beat = os.path.join(harness, "audit-heartbeat.txt")
    board = os.path.join(harness, "audit-board.html")
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if not os.path.isdir(os.path.join(repo, "backlog", "tasks")):
        os.makedirs(harness, exist_ok=True)
        with io.open(log, "a", encoding="utf-8") as f:
            f.write(f"{ts} 실패=원장없음({repo}/backlog/tasks)\n")
        print(f"error: {repo}/backlog/tasks 가 없다", file=sys.stderr)
        return 1

    n = next_round(log)
    tasks = ap.load(repo)
    order = ap.statuses_of(repo)
    a = ap.analyse(tasks, order)
    findings = len(a["ready"]) + len(a["reversed"])

    os.makedirs(harness, exist_ok=True)
    io.open(board, "w", encoding="utf-8").write(
        ap.render(repo, tasks, a, order, f"{n}회차(기계부)")
    )

    srv = ensure_server(harness, port) if port else "미설정"

    with io.open(beat, "w", encoding="utf-8") as f:
        f.write(f"{ts}\n")
        f.write(f"회차={n} 미이행={len(a['caps'])}/{len(tasks)} 어긋남={findings}\n")
        f.write(f"착수가능·미착수={a['ready'] or '없음'} 순서역전="
                f"{[t for t, _ in a['reversed']] or '없음'}\n")
        f.write(f"발동=자동(OS크론) 기계부만 — C·D 는 세션이 판단한다\n")
        f.write(f"패널서버={srv}\n")

    with io.open(log, "a", encoding="utf-8") as f:
        f.write(f"{ts} 회차={n} 발동=자동(OS크론) 어긋남={findings} "
                f"미이행={len(a['caps'])}/{len(tasks)} 서버={srv}\n")

    print(f"round={n} tasks={len(tasks)} findings={findings} "
          f"caps={len(a['caps'])} ready={a['ready']} "
          f"reversed={[t for t, _ in a['reversed']]} server={srv}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
