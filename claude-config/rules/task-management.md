# 작업 태스크 관리 (Task Management)

> **소유 범위**: `CLAUDE.md <work_continuity>` 3층 중 **작업 원장(층 ②)만**. 연속성(handoff)과
> 영구 지식은 그쪽이 소유하고 여기서 재서술하지 않는다. 세션 인계 절차는 `session-handover.md`.
>
> **도구**: **Backlog.md** (`brew install backlog-md`). 채택 근거와 기각한 대안은
> `~/MyProject/DevInfra/docs/design/2026-08-30-wiki-task-tooling-decision.md` §후속이 정본이다.
> 재조사(2026-09-07)에서 Task Master AI(API 키 필요)·Beads(정본이 DB)·OpenSpec을 검토해 **유지**로
> 결론했다. 어느 도구도 "상태 갱신 누락"을 자체로 막지 못한다 — 그것은 §9 훅이 담당한다.
>
> **실측 환경 2026-09-07 (mac redstar)**: `backlog` **1.50.1** (`/opt/homebrew/bin/backlog`) ·
> Claude Code `2.1.263` · `/usr/bin/python3` 3.9.6. 이 문서의 명령·출력·함정은 이 조합에서 직접 얻었다.
>
> **Codex에서 쓸 때**: 원칙은 같고 **배선만 다르다**(`AGENTS.md`·MCP 전역 등록).
> `~/MyProject/DevInfra/docs/design/2026-08-30-backlog-md-codex-guide.md`가 소유한다 — 여기서 재서술하지 않는다.
> ⚠️ **훅(§9)은 Claude Code 기능이다. Codex 세션에는 게이트도 브리핑도 걸리지 않는다** — 알고 쓴다.

---

## §1. 원칙 6개

1. **정본은 리포 안 평문 md다.** 태스크 1개 = 파일 1개(`backlog/tasks/<id> - <title>.md`).
   도구를 버려도 태스크는 읽을 수 있는 md로 남는다 — 탈출 비용 0이 채택 이유다.
2. **태스크는 ID로 가리킨다. 줄 번호로 가리키지 않는다.** `TASKS.md:42`는 편집마다 밀려서 낡는다.
   `TASK-42`는 밀리지 않는다. **인계·handoff·커밋 메시지·대화에서 전부 ID를 쓴다.**
3. **차단은 상태가 아니라 의존이다.** 선행 조건이 있으면 `--dep`으로 걸고, 상태는 건드리지 않는다.
   도구가 차단 관계를 계산해 보여주므로 사람이 "⛔"를 손으로 관리하지 않는다.
4. **실행 상태는 인수기준 체크박스로 표현한다.** 태스크가 "진행 중"인 것과 "무엇까지 됐는지"는 다른 정보다.
   후자는 AC 체크(`--check-ac N`)가 담는다 — 이것이 세션이 넘어갈 때 가장 값어치 있는 신호다.
5. **원장은 태스크만 담는다.** 결정·판정 근거·문서 인덱스는 층 ③으로 보낸다(§4).
6. **적는 수치는 그 턴에 직접 돌린 출력만.** `<work_continuity>` ③을 그대로 계승한다.

## §2. 상태 4개

`backlog/config.yml`의 `statuses`에 아래를 둔다. **기본 3개에 `Awaiting Decision`을 더한 것이 표준이다.**

| 상태 | 뜻 | 이전 기호 |
|---|---|---|
| `To Do` | 착수 가능 | `⏭ 대기` |
| `In Progress` | 진행 중 | `🔨 진행 중` |
| `Awaiting Decision` | **작업이 아니라 사람의 결정을 기다린다** | `⏸ 캡틴 결정 대기` |
| `Done` | 완료 | `✅ 완료` |

`⛔ 차단`은 상태가 아니다 → `dependencies`로 표현한다(원칙 3).
`Awaiting Decision`을 따로 두는 이유: `To Do`에 섞이면 "왜 안 하고 있나"를 매 세션 다시 조사하게 된다.

### 결정 대기 프로토콜 — 답을 받은 턴에 닫는다

훅(§9)은 "결정이 내려졌다"를 관측할 수 없다(사용자 발언 내용을 판정해야 하므로). 그래서 이 순서는 규칙이 소유한다.

1. 결정이 필요하면 해당 태스크를 `Awaiting Decision`으로 두고 **AskUserQuestion**으로 묻는다.
2. **답을 받은 그 턴에** 상태를 `In Progress`(또는 `To Do`)로 되돌린다. 다음 턴으로 미루지 않는다.
3. 결정과 그 근거는 층 ③(`docs/design/**`)에 남긴다 — 원장에 쓰지 않는다(§4).

빠뜨려도 유실되지는 않는다: SessionStart 브리핑이 `사람의 결정 대기`로 매 세션 다시 올리고,
그것에 의존하는 태스크가 `선행 대기`에 남아 파이프라인이 눈에 보이게 멈춘다(§9).

## §3. 일상 조작

**`--plain`을 항상 붙인다.** `backlog task list`는 기본이 인터랙티브 TUI라서 TTY 없는 셸에서 멈춘다.

```bash
backlog task create "<제목>" -d "<설명>" --ac "<기준1>" --ac "<기준2>" --plain   # AC는 반복 지정
backlog task create "<제목>" --dep TASK-1 --plain      # 선행 조건
backlog task create "<제목>" -p TASK-2 --plain         # 서브태스크 → TASK-2.1 로 생성
backlog task edit TASK-1 -s "In Progress"              # 상태 전환
backlog task edit TASK-1 --check-ac 1                  # 인수기준 1건 충족
backlog task list --plain                              # ← --plain 없으면 TUI로 멈춘다
backlog task list -s "To Do" --plain
backlog task list --ready --plain                      # 의존이 풀린 것만
backlog task view TASK-1 --plain                       # AC 체크 상태를 보는 유일한 방법 (§6)
backlog board                                          # 보드 (다른 브랜치 상태까지 병합)
backlog overview                                       # 통계
backlog browser                                        # 웹 UI 대시보드 (§10)
backlog doctor                                         # ID 중복 진단·복구 (§6의 ID 재발급 함정)
```

**갱신 리듬은 커밋과 같다.** 계획 직후 전체 태스크를 등록하고, 태스크 완료마다 상태와 AC를 고친다.
읽지 않고 착수하지 않는다.

## §4. 원장에 넣지 않는 것 — 실측으로 얻은 경계

`OhMyEnglish/TASKS.md` 315줄·표 92행을 분류했을 때 **약 40%가 태스크가 아니었다.** 일괄 변환하면
결정 기록이 태스크로 변질된다. 아래는 층 ③(`docs/design/**`, `docs/ops/pitfalls.md`)으로 보낸다.

- 캡틴 결정과 그 근거 → `docs/design/`
- 판정 근거·grep 증거·"지우면 안 되는 이유" → `docs/design/` 또는 `docs/ops/pitfalls.md`
- "구성 완료" 같은 사후 기록 → 영구 지식
- 관련 문서 지도·인덱스 → `README.md`
- 상태 기호 정의 → 도구의 `statuses` 설정으로 흡수(§2)

판별 질문: **"이것을 누가 언제 끝내는가?"에 답이 없으면 태스크가 아니다.**

**감사 결과도 태스크가 아니다.** "선행 풀림 3건"·"증거 부재 1건"은 끝낼 사람이 없는 관측값이다 →
원장 **옆**에 둔다(`.harness/audit-board.html`). 원장을 밖에서 감사하는 절차는
`~/.claude/skills/external-audit/`가 소유한다 — 여기서 재서술하지 않는다.

## §5. 프로젝트 도입 절차

### 트리거 — 되묻지 않고 돌린다

**새 프로젝트에서 "태스크/작업 계획을 관리해달라"는 요청을 받으면 `backlog init`을 먼저 돌린다.**
도입 여부를 다시 묻지 않는다 — 이미 확정된 결정이다. `backlog/`가 이미 있으면 건너뛴다.

확인이 필요한 것은 init 여부가 아니라 이 둘이다:
`CLAUDE.md`·`AGENTS.md`·`backlog/`가 이미 있어 **덮어쓸 위험이 있는가**, 그리고 **git remote가 있는가**
(없으면 `remoteOperations false`).

```bash
cd <리포>
backlog init "<프로젝트명>" --defaults --integration-mode mcp --auto-open-browser false
claude mcp add --scope project backlog -- backlog mcp start
# backlog/config.yml 의 statuses 에 "Awaiting Decision" 추가 (§2)
backlog config set remoteOperations false   # git remote 가 없을 때만. 붙이면 true 로 되돌린다
```

**착수 전 확인**: `CLAUDE.md`·`AGENTS.md`·`backlog/`가 이미 있는지 본다 — `init`이 덮어쓸 수 있다.
`auto_commit`은 기본 `false`이므로 깜짝 커밋은 없다.
**MCP는 프로젝트 스코프**로 등록한다 → `.mcp.json`이 생기고, 그 리포에서 작업하는 세션이 승인해야 붙는다.
MCP를 켜는 이유: 상태 갱신이 사람 손을 거치지 않아 일관성이 가장 높아진다.

## §6. 실측 함정

**⛔ 절대 규약 — `backlog cleanup`을 쓰지 않는다.** 이것이 유일한 하드 금지다.
`cleanup`은 오래된 완료 태스크를 `backlog/completed/`로 옮기는데, 그 폴더는 `backlog/tasks/`의
**형제**라 훅(§9)의 파싱 범위 밖이다. 옮겨진 태스크에 의존하는 태스크가 하나라도 있으면
**미커밋 0건·상태 정합인 리포가 매 턴 차단된다**(2026-09-07 재현). 그리고 훅이 보관 폴더를 읽도록
고치면 더 나빠진다 — 아래 "ID를 재발급한다" 때문에 **살아있는 태스크가 폐기된 태스크에 덮여
브리핑에서 사라진다**(재현). 원장은 평문 md라 `tasks/`에 다 쌓아 두는 비용이 낮다.
이미 옮긴 것이 있으면 **`backlog/tasks/`로 되돌린다** — 의존을 지우지 않는다(기록이 파괴된다).

**도구가 조용히 틀리는 것 4개:**

- **`task list --json`에 AC가 없다.** 노출되는 것은 id/title/status/priority/labels/ordinal뿐이다.
  AC 체크 상태를 기계적으로 읽으려면 `task view <id> --plain`이나 md 직접 파싱이 필요하다.
- **순환 의존을 검출하지 않는다.** `TASK-1→TASK-2→TASK-1`을 그냥 받아들인다. 사이클에 걸린
  태스크는 **`--ready`에서 통째로 사라져** 파이프라인이 조용히 멈춘다.
- **서브태스크가 부모의 의존을 상속하지 않는다.** `TASK-2`가 `TASK-1`을 기다리는 중에도
  `TASK-2.1`이 `--ready`에 뜬다. 훅의 브리핑이 이것을 보정한다(§9).
- **보관된 ID를 재발급한다.** `TASK-2`를 보관한 뒤 새 태스크를 만들면 **다시 `TASK-2`를 발급한다**
  (2026-09-07 직접 관측). 중복이 생겼으면 `backlog doctor`로 진단·복구한다.

**조작 함정:**

- **`--ac`는 쉼표로 분리되지 않는다.** `--ac "a,b"`는 AC 1건이 된다. 2건은 `--ac "a" --ac "b"`.
- **`statuses`는 CLI로 못 바꾼다.** `backlog config set statuses ...`는 거부된다 → `backlog/config.yml` 직접 편집.
- **config 키가 CLI는 camelCase, 파일은 snake_case다.** `backlog config set remoteOperations false`
  → 파일에는 `remote_operations: false`. **`grep remoteOperations config.yml`은 안 잡힌다.**
- **`--defaults`를 빼면 대화형 위저드**로 들어간다 — 비대화형 셸에서는 항상 `--defaults`.
- **`task delete`는 문법이 다르다.** 태스크 파일을 `rm`해도 도구는 정상 동작한다(정본이 평문 md라서).
- **remote가 없으면 매 명령마다 경고가 난다.** `remoteOperations false`로 내리고, remote를 붙이면 되돌린다.

## §7. 도입 상태 · 미도입 프로젝트

2026-08-30 실측 — 네 리포 모두 MCP 프로브에서 `tools=20`, 첫 리소스 `backlog://workflow/overview` 확인.

| 프로젝트 | 상태 |
|---|---|
| `OhMyEnglish` | `init`+MCP 완료. `TASKS.md` 마이그레이션은 차단 중(비태스크 37행 분류 승인 대기) |
| `En-Coach` | `init` 완료. `backlog/`는 **미추적** — 다른 세션이 작업 중이라 커밋 시점을 그쪽에 맡겼다 |
| `WSEAgent` | `init` 완료·커밋(`23af084`) |
| `DevInfra` | `init` 완료·커밋(`f348da4`) |
| `cursor-todo-app` · 그 외 | 미도입 — §5 트리거에 따라 태스크 관리 요청 시 init |

**미도입 리포에서는 기존 `TASKS.md` 표를 그대로 쓴다.** 단 **원칙 2(ID로 가리킨다)는 지금부터 적용한다** —
줄 번호 대신 표의 태스크 번호(`Task 8`)로 지목한다. 도구 도입 여부와 무관하게 줄 번호는 쓰지 않는다.

## §8. 계층과 의존

> §1~§7의 번호는 다른 문서가 참조하므로(예: `skills/external-audit/SKILL.md`가 §4를 가리킨다)
> 새 내용은 뒤에 붙인다. **번호를 재배치하지 않는다.**

- **서브태스크**: `-p TASK-2` → ID가 `TASK-2.1`, `TASK-2.2`로 자동 생성된다. frontmatter에
  `parent_task_id: TASK-2`가 들어간다.
- **의존**: `--dep TASK-1` (`--depends-on` 축약). 소문자로 줘도 `TASK-1`로 정규화된다.
- **착수 순서**: `--ready`가 계산한다. 단 §6의 함정 2개(순환 미검출·부모 의존 미상속)를 반드시 안다 —
  그래서 §9의 브리핑이 보정한다.

## §9. 기계적 집행 — 훅 2개

규칙 준수에만 맡기지 않는다. 2026-09-07 설치. 등록은 `~/.claude/settings.json`에 있고
**`matcher`를 넣지 않는다** — 넣으면 등록만 되고 발화하지 않는다(원본 mac 실측).

| 훅 | 이벤트 | 하는 일 |
|---|---|---|
| `hooks/backlog-session-brief.py` | SessionStart | 잔여/완료 집계, **이어서 진행**(In Progress + 미충족 AC), **착수 가능**, **결정 대기**, **선행 대기**, 그래프 이상을 세션 컨텍스트에 주입 |
| `hooks/backlog-task-gate.py` | Stop · SubagentStop | 원장이 틀어진 채 턴이 끝나는 것을 **exit 2로 차단** |

차단 조건 5개 — 모두 오탐이 없는 조건만 골랐다. "In Progress인데 AC 미체크"는 정상적인 작업
중간 상태이므로 차단하지 않는다:

| | 차단 조건 |
|---|---|
| G1 | 미커밋 변경이 있는데 `In Progress` 태스크가 0건 |
| G2 | `In Progress`인데 AC가 **전부** 체크됨 (자기 기준으로 끝났는데 상태가 안 넘어감) |
| G3 | `Done`인데 미체크 AC가 남음 |
| G4 | 서브태스크 전부 `Done`인데 부모가 열려 있음 |
| G5 | 순환 의존 / 존재하지 않는 태스크에 의존 |

**설계 근거 (바꾸기 전에 읽을 것):**

- **`exit 2`만 차단한다.** 유효 JSON 없는 `exit 1`은 non-blocking 오류로 처리되어 작업이 그대로
  진행된다 — 게이트가 조용히 죽는 가장 흔한 실수다.
- **`stop_hook_active`를 읽고 조기 종료한다.** 이걸 빼면 연속 8회 차단 후 하네스가 게이트를
  **아예 무시한다**(`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`, 기본 8).
- **"잔여 태스크가 남았다"를 차단 조건으로 쓰지 않는다.** 완주를 강제하려 하면 8회 cap에 걸려
  **G1~G5 누락 방지까지 같이 죽는다.**
- **`load_tasks()`에 보관 폴더를 추가하지 않는다.** 이유는 §6의 하드 금지와 같다.
- 탈출구는 `BACKLOG_GATE=0` (두 훅 모두 즉시 no-op). 파싱 정본은 `hooks/backlog_ledger.py` 하나다.

**훅이 막지 못하는 것 — 사람이 소유한다:**

- **태스크 등록 자체의 누락.** 태스크 1건만 claim하고 5개 일을 하면 통과한다. **계획을 세운 직후
  전부 등록했는지 한 번 확인하는 것**이 사람의 유일한 필수 몫이다(`CLAUDE.md <work_continuity>` ②).
- **완주.** `To Do`가 9건 남아도 게이트는 통과한다(설계상 의도).
- **크래시·Esc.** Stop 훅은 사용자 인터럽트에 발화하지 않는다.
- **문서·분석 트랙과의 마찰**: 코드 변경 없이 문서만 써도 G1이 발동한다(커밋하면 풀린다).
  잔소리가 과하면 그 세션만 `BACKLOG_GATE=0`으로 내린다.

**보장 범위**: 어디서 멈춰도 **잔여 작업이 유실되지 않는다.** 원장 상태가 틀어진 채 턴이 끝나지 않는다.

## §10. 대시보드 — 2026-09-07 실측

**`backlog browser`가 도구 내장 웹 UI다.** `127.0.0.1`에만 바인딩된다(외부 노출 없음).
원장 정본이 md라 UI에서 고쳐도 파일이 바뀐다 — 별도 DB가 없다.

```bash
cd <리포> && backlog browser --port 6420 --no-open --non-interactive &
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:6420/     # 200 이면 살아 있다
```

- **리포 1개당 프로세스 1개다.** cwd에 묶이므로 다른 리포를 보려면 **다른 포트로 하나 더** 띄운다.
- **세션과 독립적으로 산다.** 실측: `OhMyEnglish`용 6420이 **1일 8시간 44분** 연속 기동 중이었고
  띄운 세션은 이미 없었다. 즉 한 번 띄우면 계속 쓴다.
- **재부팅 후에는 자동으로 안 뜬다.** `@reboot` 크론도 launchd 등록도 없다(실측). 필요하면
  launchd agent를 만든다 — 지금은 수동 재기동이 규약이다.
- 훅(§9)과 충돌하지 않는다. 훅은 md를 읽기만 하고 UI는 md를 쓴다.

**감사 패널은 다른 것이다** (`.harness/audit-board.html`, 포트 6421 — 실측 HTTP 200).
원장 **밖**의 관측값(어긋남·미이행)을 본다. 원장 옆에 두는 이유는 §4. 소유는 `skills/external-audit/`.

**둘의 차이**: `browser`는 **원장을 본다**, 감사 패널은 **원장이 맞는지를 본다.** 포트를 겹치지 않게 둔다.

---

_2026-09-07 개정 — 훅 기반 기계적 집행을 도입하면서 §2 결정 대기 프로토콜 · §3 `--plain` 필수 ·_
_§6 함정 보강(**`cleanup` 하드 금지** 포함) · §8 계층과 의존 · §9 훅 · §10 대시보드를 추가했다._
_**§1~§7의 번호는 의도적으로 보존했다** — `skills/external-audit/SKILL.md`가 §4를 가리키고_
_`CLAUDE.md`·`session-handover.md`가 §1-2를 가리킨다. 새 내용을 뒤에 붙인 이유가 그것이다._
_판단 근거와 기각한 대안(보관 폴더를 읽는 수정안 2개)은_
_`~/MyProject/DevInfra/docs/design/2026-09-07-ledger-hooks-vs-external-audit-review.md`가 소유한다._

_최초 작성: 2026-08-30. `CLAUDE.md <work_continuity>`의 원장 계층이 `TASKS.md` 수기에서 Backlog.md로_
_바뀌면서 신설. 이전에 `TASKS.md`를 원장 정본으로 지목했던 서술은 이 파일을 가리키도록 정정했다_
_(`CLAUDE.md`, `session-handover.md`, `code-development-principles.md`)._
