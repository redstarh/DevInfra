---
name: live-chrome-inspection
description: Use when the user asks what Chrome is showing right now — the current page, the visible problem or exercise, or the on-screen state — including short follow-ups like "지금 화면", "이거 뭐야", "화면 확인해", "다시 봐", "무슨 문제야". Also use when an earlier answer about the Chrome screen may be stale.
---

# Live Chrome Inspection

## The one rule

**이 턴에 직접 읽은 accessibility tree만 근거다.** 이전 스크린샷·첨부 이미지·앞선 관찰·앞선 답변·
대화 기억은 전부 무시한다. 후속 질문("그럼 다음 문제는?")도 **새로 읽는다** — 화면은 이미 바뀌었다.

## Read

```bash
python3 ~/.claude/skills/live-chrome-inspection/read-chrome.py
```

- **창을 앞으로 가져오지 않는다.** 배경에 있는 창도 그대로 읽힌다(실측: iTerm 최전면 상태에서
  읽고 포커스 유지 확인). **Chrome을 실행하지 않고, 클릭·입력·페이지 이동도 하지 않는다.**
- 성공: 1행이 `READ ok pid=… window=… truncated=…`, 그 뒤가 tree 본문.
- 실패: stderr에 `READ FAILED — <사유>`, exit 1, stdout 비어 있음.
- 필요하면 `--pid N` / `--window-id ID`로 대상을 직접 지정한다.

⚠️ **`--restore-window`를 기본으로 쓰지 말 것.** 읽기에 필요하지 않고, 이 플래그는 **번들 단위로
앱을 활성화**해서 pid를 정확히 지정했더라도 **자동화 Chrome의 빈 "New Tab" 창을 사용자 창 앞으로
올린다**(실측: `--app pid:28968 --restore-window` 직후 최전면 창이 `New Tab - Google Chrome`).
창이 `minimized=True`여서 내용이 비어 보일 때만 `--restore-window`를 붙여 다시 읽는다.

### Chrome이 여러 개다 (실측)

**이 머신에는 Chrome 메인 프로세스가 2개 이상 뜬다.** 하나는 자동화 프로필
(`--user-data-dir=…/superpowers/browser-profiles/…`, `--remote-debugging-port=…`)이고 보통
"New Tab"만 띄워져 있다. **사용자가 말하는 화면은 그게 아니다.** 스크립트는 `ps`로 메인
프로세스를 모두 찾아 자동화 표식이 없는 것만 고른다. 후보가 0개거나 2개 이상이면 멈춘다.

⚠️ **`orca computer list-apps`를 PID 근거로 쓰지 말 것** — Chrome을 **한 개만** 보고한다
(실측: 메인 2개 중 자동화 프로필만 나왔다). `orca computer list-windows`도 창이 실제로 있는데
**빈 배열을 돌려주는 경우가 있다** — `get-app-state`는 그때도 정상 동작한다.

## 답하기 전에 이 신호를 본다

| 신호 | 뜻 | 할 일 |
|---|---|---|
| `READ FAILED` (exit 1) | 읽지 못했다 | 사유를 그대로 보고한다. **질문에 답하지 않는다** |
| **`window=` 제목이 질문과 안 맞는다** (예: 질문은 문제 화면인데 `'New Tab'`) | **다른 Chrome 인스턴스를 읽었다** | `ps -eo pid,command \| grep -F '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \| grep -v -- --type=` 로 메인 프로세스를 확인하고 `--pid`로 다시 읽는다. 읽은 내용을 그대로 답하지 않는다 |
| `Chrome 이 실행 중이 아니다` | Chrome 없음 | 그렇다고 말한다. 실행하지 않는다 |
| `사용자 Chrome 이 없다 — 자동화 프로필뿐이다` | 자동화 Chrome만 떠 있다 | 그렇다고 말한다. **자동화 창을 사용자 화면으로 보고하지 않는다** |
| 창 2개 이상 | 어느 창인지 모른다 | `--window-id`로 재실행 또는 사용자 확인 |
| `minimized=True` / `offscreen=True` | 창이 화면에 없다 | 그 사실을 함께 보고한다 |
| `truncated=True` 또는 `maxDepthReached=True` | tree가 잘렸다 | "잘렸다"고 밝히고, 없는 부분을 메우지 않는다 |
| 답이 tree 본문에 없다 | 읽히지 않았다 | "읽을 수 없다"고 말한다 |

## 답변 형식 — 화면에 문제·문항이 있을 때

출력은 이 두 항목으로만 구성된다. 문항이 여러 개면 문항 단위로 블록을 반복한다.

```
- 문제
    - {tree에서 읽은 실제 문제 문장과 선택지}
- 답변
    - 정답
    - 해설 : 핵심만 한두 줄
```

- `문제`에는 tree의 문장을 그대로 옮긴다. 선택지가 화면에 없으면 `선택지 없음`이라고 적는다.
- `해설`은 한두 줄이다. 근거가 tree에 없으면 그 문항의 `정답`은 `읽을 수 없음`이다.

## Never

- **이전 읽기 결과로 답하지 않는다.** 매 요청은 새 읽기를 요구한다.
- **tree에 없는 내용을 만들지 않는다.** URL·창 제목·"보통 저 페이지엔 이런 게 있다"로 추론 금지.
- **Chrome을 실행·이동·조작하지 않는다.**
- ⚠️ `orca`는 **실패해도 exit 0**이다. orca를 직접 돌릴 때는 `$?`가 아니라 JSON의 `ok` 필드로
  판정한다(스크립트는 이미 그렇게 한다).

## 읽을 수 없을 때의 정답

추정 답이 아니라 **"읽을 수 없다"** + 실제로 본 것(실패 사유, 또는 창 제목·`elements` 수)이다.
빈손으로 보고하는 것이 틀린 답보다 낫다.
