# 작업 태스크 관리 (Task Management)

> **소유 범위**: `CLAUDE.md <work_continuity>` 3층 중 **작업 원장(층 ②)만**. 연속성(handoff)과
> 영구 지식은 그쪽이 소유하고 여기서 재서술하지 않는다. 세션 인계 절차는 `session-handover.md`.
>
> **도구**: **Backlog.md** (`brew install backlog-md`). 채택 근거와 기각한 대안은
> `~/MyProject/DevInfra/docs/design/2026-08-30-wiki-task-tooling-decision.md` §후속이 정본이다.
>
> **Codex에서 쓸 때**: 원칙은 같고 **배선만 다르다**(`AGENTS.md`·MCP 전역 등록).
> `~/MyProject/DevInfra/docs/design/2026-08-30-backlog-md-codex-guide.md`가 소유한다 — 여기서 재서술하지 않는다.

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

## §3. 일상 조작

```bash
backlog task create "<제목>" -d "<설명>" --ac "<기준1>" --ac "<기준2>"   # AC는 반복 지정
backlog task create "<제목>" --dep TASK-1                              # 선행 조건
backlog task edit TASK-1 -s "In Progress"                              # 상태 전환
backlog task edit TASK-1 --check-ac 1                                  # 인수기준 1건 충족
backlog task list -s "To Do"                                           # 상태별 조회
backlog board                                                          # 보드 (다른 브랜치 상태까지 병합)
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

- **`--ac`는 쉼표로 분리되지 않는다.** `--ac "a,b"`는 AC 1건이 된다. 2건은 `--ac "a" --ac "b"`.
- **`statuses`는 CLI로 못 바꾼다.** `backlog config set statuses ...`는 거부된다 → `backlog/config.yml` 직접 편집.
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

---

_최초 작성: 2026-08-30. `CLAUDE.md <work_continuity>`의 원장 계층이 `TASKS.md` 수기에서 Backlog.md로_
_바뀌면서 신설. 이전에 `TASKS.md`를 원장 정본으로 지목했던 서술은 이 파일을 가리키도록 정정했다_
_(`CLAUDE.md`, `session-handover.md`, `code-development-principles.md`)._
