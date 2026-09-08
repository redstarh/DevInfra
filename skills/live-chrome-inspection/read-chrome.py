#!/usr/bin/env python3
"""지금 열려 있는 사용자 Chrome 창을 Orca로 읽어 accessibility tree를 출력한다.

usage: read-chrome.py [--pid N] [--window-id ID] [--restore-window]

출력 1행은 판독 신호(READ ok pid=... truncated=...), 그 뒤가 tree 본문이다.
읽지 못하면 stderr 에 사유를 쓰고 exit 1 — 그때는 답을 만들지 말고 사유를 보고한다.

⚠️ `orca computer list-apps` 는 Chrome 을 한 개만 보고한다(실측: 메인 프로세스 2개 중
자동화 프로필 하나만 나왔다). 그래서 PID 는 ps 로 찾고, 자동화 프로필은 배제한다.

⚠️ 창을 앞으로 가져오지 않는다. 배경 상태에서도 정상 읽힌다(실측). `--restore-window` 는
번들 단위로 앱을 활성화해서 **자동화 Chrome 의 빈 "New Tab" 창을 사용자 창 앞으로 올린다** —
기본에서 뺀 이유다.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from typing import NoReturn

CHROME_MAIN_PATH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# 자동화로 띄운 Chrome 표식 — 사용자가 보는 창이 아니다.
AUTOMATION_FLAGS = ("--user-data-dir=", "--remote-debugging-port=")


def die(reason: str) -> NoReturn:
    print(f"READ FAILED — {reason}", file=sys.stderr)
    sys.exit(1)


def orca_json(args: list[str]) -> dict:
    """orca 를 JSON 모드로 실행한다. orca 는 실패해도 exit 0 이므로 ok 필드로 판정한다."""
    proc = subprocess.run(["orca", *args, "--json"], capture_output=True, text=True, check=False)
    if not proc.stdout.strip():
        die(f"orca 무응답: {' '.join(args)} / stderr={proc.stderr.strip()[:200]}")
    try:
        payload = json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        die(f"orca 출력 파싱 실패: {exc} / stdout={proc.stdout[:200]}")
    if not payload.get("ok"):
        err = payload.get("error", {})
        die(f"orca 실패: code={err.get('code')} message={err.get('message')}")
    return payload["result"]


def chrome_main_processes() -> list[tuple[int, str]]:
    """Chrome 메인 프로세스만 반환한다. 렌더러(--type=)와 Helpers/crashpad 는 제외된다."""
    proc = subprocess.run(["ps", "-eo", "pid=,command="], capture_output=True, text=True, check=False)
    found = []
    for line in proc.stdout.splitlines():
        pid_str, _, command = line.strip().partition(" ")
        if not command.startswith(CHROME_MAIN_PATH) or "--type=" in command:
            continue
        if pid_str.isdigit():
            found.append((int(pid_str), command))
    return found


def window_labels(pid: int) -> str:
    windows = orca_json(["computer", "list-windows", "--app", f"pid:{pid}"]).get("windows", [])
    return " | ".join(f"id:{w.get('id')} {w.get('title')!r}" for w in windows) or "창 없음"


def find_user_chrome_pid() -> int:
    processes = chrome_main_processes()
    if not processes:
        die("Chrome 이 실행 중이 아니다. 실행하지 말 것")

    user = [pid for pid, cmd in processes if not any(f in cmd for f in AUTOMATION_FLAGS)]
    automation = [pid for pid, cmd in processes if any(f in cmd for f in AUTOMATION_FLAGS)]

    if len(user) == 1:
        return user[0]
    if not user:
        die(
            f"사용자 Chrome 이 없다 — 자동화 프로필뿐이다(pid {automation}). "
            "자동화 창을 사용자 화면으로 보고하지 말 것"
        )
    listed = " / ".join(f"pid:{p} → {window_labels(p)}" for p in user)
    die(f"사용자 Chrome 이 {len(user)}개다 — 추측하지 말 것. {listed} → --pid 로 지정하거나 사용자에게 확인")


def main() -> None:
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("--pid", type=int, help="읽을 Chrome PID를 직접 지정")
    parser.add_argument("--window-id", help="읽을 창 id를 직접 지정")
    parser.add_argument(
        "--restore-window",
        action="store_true",
        help="창을 앞으로 가져온 뒤 읽는다. 기본은 끔 — 읽기는 배경 상태에서도 되고, "
        "이 플래그는 번들 단위로 앱을 활성화해 자동화 Chrome 창을 앞으로 올린다(실측). "
        "minimized 창을 읽어야 할 때만 쓴다",
    )
    opts = parser.parse_args()

    pid = opts.pid or find_user_chrome_pid()

    if not opts.window_id:
        windows = orca_json(["computer", "list-windows", "--app", f"pid:{pid}"]).get("windows", [])
        # ⚠️ list-windows 는 창이 실제로 있어도 빈 배열을 돌려주는 경우가 있다(실측: pid 28968).
        #    그때도 get-app-state 는 정상 동작하므로 "창 없음"으로 막지 않는다.
        #    창이 2개 이상이라고 **보고될 때만** 멈춘다 — 그건 확실한 모호성 신호다.
        if len(windows) > 1:
            labels = " | ".join(f"id:{w.get('id')} {w.get('title')!r}" for w in windows)
            die(f"창이 {len(windows)}개다 — 어느 창인지 추측하지 말 것. {labels} → --window-id 로 지정")

    args = ["computer", "get-app-state", "--app", f"pid:{pid}", "--no-screenshot"]
    if opts.window_id:
        args += ["--window-id", opts.window_id]
    if opts.restore_window:
        args.append("--restore-window")

    snap = orca_json(args)["snapshot"]
    win, trunc = snap["window"], snap["truncation"]
    print(
        f"READ ok pid={pid} window={win['title']!r} minimized={win['isMinimized']} "
        f"offscreen={win['isOffscreen']} elements={snap['elementCount']} "
        f"truncated={trunc['truncated']} maxDepthReached={trunc['maxDepthReached']}"
    )
    if (win["isMinimized"] or win["isOffscreen"]) and not opts.restore_window:
        print(
            "HINT 창이 minimized/offscreen 이다. 내용이 비어 보이면 --restore-window 로 다시 읽는다 "
            "(단 그 플래그는 자동화 Chrome 창을 앞으로 올린다)",
            file=sys.stderr,
        )
    print(snap["treeText"])


if __name__ == "__main__":
    main()
