# 세션 인계 (Session Handover)

> 원칙은 `CLAUDE.md` `<work_continuity>`. 이 문서는 **실행 절차와 명령**만 담는다.
> 환경 실측(2026-08-28): tmux **3.6a** · iTerm2 **3.6.11**(osascript 가능) ·
> 세션 이름 규칙 `claude_air_<그룹>-<번호>`.
> ⚠️ tmux에 **`send-message`는 없다.** 세션 간 통신은 `send-keys`이고 동기화는 `wait-for`다.

---

## 1. 인계 트리거 — 언제 마감하는가

먼저 오는 것 하나로 발동한다. **한 태스크 중간에 끊지 않는다** — 태스크 경계에서만.

| 트리거 | 어떻게 아는가 |
|---|---|
| 남은 컨텍스트 **≲35%** | 시스템 리마인더의 `total_tokens left`를 쓴다. **절대 백분율을 확신할 수 없으면** 그 수치를 그대로 사용자에게 보고하고 판단을 구한다 — 추정치를 사실처럼 쓰지 않는다 |
| auto-compact 경고를 봤다 | 하네스가 알려준다. 이미 늦은 신호이므로 즉시 마감 |
| 태스크 **3개 연속** 완료 | 세어서 안다. 컨텍스트를 못 재도 이 조건은 잴 수 있다 |

**왜 70%가 아니라 65% 부근인가**: 인계 확인 자체가 컨텍스트를 쓴다(양방향 보고 + 대조).
70%에서 시작하면 확인 대화 중에 바닥난다. 마감 + 확인까지의 여유를 남긴다.

---

## 2. 마감 (이전 세션)

1. 진행 중 작업을 **커밋 가능한 상태로** 만든다. 반쯤 고친 코드를 남기지 않는다.
2. 게이트를 직접 돌려 실측값을 확보한다(`<verification>`).
3. **원장**의 태스크 상태 · **handoff**의 다음 한 걸음을 갱신하고 커밋한다. 원장은 Backlog.md이고 조작은 `task-management.md`가 소유한다 — 미도입 리포에서는 기존 `TASKS.md` 표를 쓴다.
4. handoff에 **인계 지표 4개**를 적는다 (§4).

---

## 3. 새 세션 생성 — iTerm2 전면에 띄운다

**백그라운드 detached로 만들지 않는다.** 사용자가 볼 수 있어야 한다.

```bash
# 번호는 기존 최대값 +1 (이름 규칙을 발명하지 않는다)
PREFIX=$(tmux display-message -p '#{session_group}')      # 예: claude_air_3
LAST=$(tmux ls -F '#{session_name}' | sed -n "s/^${PREFIX}-\([0-9]*\)$/\1/p" | sort -n | tail -1)
NEW="${PREFIX}-$((LAST+1))"

# iTerm2 새 창에서 그 tmux 세션을 붙인 채로 띄운다.
# ⚠️ tmux를 **절대 경로**로 준다 — iTerm은 이 command를 로그인 셸 없이 exec하므로
#    `/opt/homebrew/bin`이 PATH에 없다. `tmux`라고 쓰면 창만 열리고 세션은 안 생긴다(실측).
osascript -e "tell application \"iTerm\" to create window with default profile \
  command \"$(command -v tmux) new-session -s ${NEW} -c $(pwd)\""

# **만들었다고 가정하지 말고 확인한다.** osascript는 window id를 돌려주고 exit 0이지만
# 안쪽 명령이 실패해도 그렇다.
tmux ls | grep -q "^${NEW}:" && echo "생성됨: ${NEW}" || echo "실패 — 창 안의 오류를 보라"
```

만들었으면 **사용자에게 세션 이름을 알린다.** 새 창에서 Claude Code를 띄우는 것은 사용자가
하거나, 사용자가 위임했으면 그 창에 `send-keys`로 명령을 넣는다.

---

## 4. 인계 확인 — "읽었다"가 아니라 "같은 값을 얻었다"

새 세션은 handoff를 읽은 뒤 **자기가 직접 돌려** 아래 4개를 보고한다. 이전 세션이 기록한
값과 **전부 일치**해야 인계 완료다. 하나라도 다르면 **그 차이를 먼저 설명한다.**

| # | 지표 | 새 세션이 얻는 방법 |
|--:|---|---|
| 1 | HEAD 커밋 해시 | `git rev-parse --short HEAD` |
| 2 | 다음 한 걸음 — **태스크 ID**와 제목 | `backlog task list -s "In Progress"` / `To Do`를 **직접 실행**해 얻고 한 줄로 복창 |
| 3 | 게이트 실측 수치 | 테스트·lint·타입 검사를 **직접 실행** |
| 4 | 착수 전 필수 조건 개수와 요지 | 해당 태스크의 `dependencies`와 미충족 AC를 열거 |

3번이 핵심이다 — 읽기는 전달을 증명하지 못하고, **직접 돌린 출력**만 데이터다.

⚠️ **2·4번을 줄 번호로 지목하지 않는다** (`TASKS.md:42` 금지). 줄 번호는 편집마다 밀려서
다음 세션이 엉뚱한 줄을 읽는다 — **태스크 ID로 지목한다** (`task-management.md` §1-2).
2번이 `backlog` 명령의 출력인 것도 같은 이유다: 읽은 값이 아니라 **돌려서 얻은 값**이어야 한다.
Backlog.md 미도입 리포에서는 표의 태스크 번호(`Task 8`)로 지목한다 — 줄 번호는 여기서도 쓰지 않는다.

---

## 5. 세션 간 통신 (`send-keys`)

```bash
TARGET=claude_air_3-15          # 상대 세션
tmux send-keys -t "$TARGET" '보고: HEAD=abc1234 다음=Task7 게이트=312 passed 필수=3건'
tmux send-keys -t "$TARGET" Enter
sleep 1
tmux send-keys -t "$TARGET" Enter        # 긴 한 줄은 첫 Enter가 삼켜진다 (실측)
tmux capture-pane -p -t "$TARGET" | tail -5   # 도착을 눈으로 확인
```

동기화가 필요하면 `wait-for`를 쓴다: 대기 측 `tmux wait-for handover`, 신호 측
`tmux wait-for -S handover`.

---

## 6. 정리 순서 — 이 순서를 바꾸지 않는다

1. 새 세션이 §4의 4개를 보고한다.
2. **이전 세션이 대조하고, 그 결과를 handoff에 기록한다** (`인계 확인: 4/4 일치, 2026-..-.. 새 세션 <이름>`).
3. 이전 세션이 종료한다(`/exit`).
4. **새 세션이** 이전 tmux 세션을 kill한다: `tmux kill-session -t <이전>`.

**자기 자신을 kill하지 않는다** — 확인 기록을 남길 주체가 사라진다.
**추측으로 정리하지 않는다** — 4개 지표가 데이터로 일치하기 전에는 이전 세션을 살려 둔다.
불일치가 남았는데 컨텍스트가 바닥나면, **정리하지 않고 사용자에게 그 사실을 보고한다.**

---

_최초 작성: 2026-08-28 — 캡틴 지시(컨텍스트 70% 마감 + tmux 인계 확인)를 실행 가능한 형태로._
_2026-08-28 실측 정정: iTerm `command`는 로그인 셸을 거치지 않아 `tmux`를 절대 경로로 줘야 한다 —
첫 시도가 창만 열고 세션을 만들지 못했다. 생성 후 `tmux ls`로 확인하는 줄을 추가했다._

_반영한 정정 5건: 컨텍스트 백분율을 직접 못 재는 문제 / kill 주체 / `send-message`→`send-keys` /
"전달됨"의 지표 구체화 / 확인 대화 여유를 위한 트리거 앞당김._
