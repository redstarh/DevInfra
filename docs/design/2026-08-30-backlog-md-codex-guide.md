# Backlog.md를 Codex에서 쓰기 — 핵심 가이드

> **왜 따로 있나**: 원칙은 Claude Code와 같지만 **배선이 다르다.** Codex는 `CLAUDE.md`가 아니라
> `AGENTS.md`를 읽고, MCP 설정 파일과 **등록 범위**가 다르다. Claude Code 쪽 정본은
> `~/.claude/rules/task-management.md`이고, 이 문서는 **Codex가 단독으로 읽어도 되도록 자기완결적**으로 쓴다.
>
> 채택 근거(왜 Gitea가 아니고 Backlog.md인가)는 `2026-08-30-wiki-task-tooling-decision.md` §후속.

**환경 실측 (2026-08-30)**: `codex-cli 0.151.0` · `backlog 1.50.1`(brew) ·
Codex 전역 지침 `~/.codex/AGENTS.md` · Codex MCP 설정 `~/.codex/config.toml`

---

## §1. 설치

```bash
brew install backlog-md      # backlog 1.50.1
backlog --version
```

## §2. Claude Code와 다른 3가지 — 여기만 다르다

| 항목 | Claude Code | **Codex** |
|---|---|---|
| 전역/프로젝트 지침 파일 | `CLAUDE.md` | **`AGENTS.md`** |
| MCP 등록 명령 | `claude mcp add --scope project backlog -- backlog mcp start` | **`codex mcp add backlog -- backlog mcp start`** |
| MCP 등록 범위 | 프로젝트 (`<리포>/.mcp.json`) | **전역** (`~/.codex/config.toml`) — 스코프 옵션이 없다 |

**전역 등록의 함의**: 서버가 **cwd에서 Backlog root를 찾는다**(`backlog mcp start --cwd <path>`,
또는 `BACKLOG_CWD` 환경변수). 그래서 **프로젝트마다 다시 등록할 필요가 없다** — 한 번 등록하면
어느 리포에서 Codex를 띄우든 그 리포의 `backlog/`를 본다.

주의: `backlog/`가 없는 디렉터리에서 Codex를 띄우면 루트가 없는 서버가 붙는다. 특정 리포로 고정하려면
`codex mcp add backlog -- backlog mcp start --cwd /path/to/repo`로 등록한다.

## §3. 배선 — 두 갈래 중 하나만

⚠️ **병용할 수 없다.** `--integration-mode mcp`는 `--agent-instructions`와 결합이 거부된다.

### A. MCP (권장 — Claude Code 설정과 일치)

```bash
cd <리포>
backlog init "<프로젝트명>" --defaults --integration-mode mcp --auto-open-browser false
codex mcp add backlog -- backlog mcp start
codex mcp list                                   # backlog 가 보이는지 확인
```

에이전트가 태스크 상태를 **직접 읽고 갱신**하므로 사람 손을 거치지 않아 일관성이 가장 높다.

### B. 파일 지침 (MCP를 쓰지 않을 때)

```bash
cd <리포>
backlog init "<프로젝트명>" --defaults --agent-instructions agents
# → 리포에 AGENTS.md 가 생성된다. Codex 가 그것을 읽는다
```

`--agent-instructions` 유효값: `claude, agents, gemini, copilot, cursor, none`.
**Codex용은 `agents`다** (`codex`라는 값은 없다 — `agents`가 `AGENTS.md`를 쓴다).

### 착수 전 확인

`init`이 덮어쓸 수 있으므로 **`AGENTS.md`·`CLAUDE.md`·`backlog/`가 이미 있는지 먼저 본다.**
`auto_commit`은 기본 `false`라 깜짝 커밋은 없다.

## §4. 원칙 6개 — Codex도 동일하다

1. **정본은 리포 안 평문 md다.** 태스크 1개 = 파일 1개(`backlog/tasks/<id> - <title>.md`).
   도구를 버려도 태스크는 읽을 수 있는 md로 남는다 — 탈출 비용 0이 채택 이유다.
2. **태스크는 ID로 가리킨다. 줄 번호로 가리키지 않는다.** `TASKS.md:42`는 편집마다 밀려서
   다음 세션이 엉뚱한 줄을 읽는다. `TASK-42`는 밀리지 않는다. **인계·커밋 메시지·대화에서 전부 ID를 쓴다.**
3. **차단은 상태가 아니라 의존이다.** 선행 조건은 `--dep`으로 걸고 상태는 건드리지 않는다.
   도구가 차단 관계를 계산해 보여준다 — 사람이 "⛔"를 손으로 관리하지 않는다.
4. **실행 상태는 인수기준 체크박스로 표현한다.** "진행 중"인 것과 "무엇까지 됐는지"는 다른 정보다.
   후자는 `--check-ac N`이 담고, **세션이 넘어갈 때 가장 값어치 있는 신호**다.
5. **원장은 태스크만 담는다.** 결정·판정 근거·문서 인덱스는 원장이 아니라 `docs/`로 보낸다(§7).
6. **적는 수치는 그 턴에 직접 돌린 출력만.** 계산값·낡은 값 금지.

## §5. 상태 4개

`backlog/config.yml`의 `statuses`에 아래를 둔다. **기본 3개에 `Awaiting Decision`을 더한 것이 표준이다.**

| 상태 | 뜻 |
|---|---|
| `To Do` | 착수 가능 |
| `In Progress` | 진행 중 |
| `Awaiting Decision` | **작업이 아니라 사람의 결정을 기다린다** |
| `Done` | 완료 |

`Awaiting Decision`을 따로 두는 이유: `To Do`에 섞이면 "왜 안 하고 있나"를 매 세션 다시 조사하게 된다.
차단(선행 조건 있음)은 **상태가 아니라 `dependencies`**다(원칙 3).

## §6. 일상 명령

```bash
backlog task create "<제목>" -d "<설명>" --ac "<기준1>" --ac "<기준2>"   # AC는 반복 지정
backlog task create "<제목>" --dep TASK-1                              # 선행 조건
backlog task edit TASK-1 -s "In Progress"                              # 상태 전환
backlog task edit TASK-1 --check-ac 1                                  # 인수기준 1건 충족
backlog task list -s "To Do"                                           # 상태별 조회
backlog board                                                          # 보드 (다른 브랜치 상태까지 병합)
```

**갱신 리듬은 커밋과 같다.** 계획 직후 전체 태스크를 등록하고, 태스크 완료마다 상태와 AC를 고친다.

## §7. 원장에 넣지 않는 것 — 실측으로 얻은 경계

`OhMyEnglish/TASKS.md` 315줄·표 92행을 분류했을 때 **약 40%가 태스크가 아니었다.**
일괄 변환하면 결정 기록이 태스크로 변질된다. 아래는 `docs/`로 보낸다.

- 사람의 결정과 그 근거 · 판정 근거·grep 증거 · "구성 완료" 같은 사후 기록 · 문서 인덱스
- 상태 기호 정의 → 도구의 `statuses` 설정으로 흡수(§5)

판별 질문: **"이것을 누가 언제 끝내는가?"에 답이 없으면 태스크가 아니다.**

## §8. 실측 함정 4건

- **`--ac`는 쉼표로 분리되지 않는다.** `--ac "a,b"`는 AC **1건**이 된다. 2건은 `--ac "a" --ac "b"`.
- **`statuses`는 CLI로 못 바꾼다.** `backlog config set statuses ...`는 거부된다 →
  `backlog/config.yml`을 직접 편집한다.
- **삭제는 `task delete`가 아니다.** 그 문법은 거부된다 — MCP는 `task_archive`를 노출한다.
  급하면 태스크 파일을 `rm`해도 도구는 정상 동작한다(정본이 평문 md라서).
- **git remote가 없으면 매 명령마다 경고가 난다.** `backlog config set remoteOperations false`로
  내리고, remote를 붙이면 `true`로 되돌린다.

## §9. Codex에 원칙을 심기

MCP만 붙이면 *도구*는 쓰지만 *원칙*(원칙 2의 ID 지목 등)은 지켜지지 않는다. 둘 중 하나로 심는다.

- **전역**: `~/.codex/AGENTS.md`에 이 문서를 가리키는 한 줄을 넣는다.
  현재 그 파일은 6줄(`# Global Codex Instructions` + HTML preview)이라 충돌 없이 추가할 수 있다.
- **프로젝트별**: 리포의 `AGENTS.md`에 같은 포인터를 넣는다.

포인터 예:

```markdown
## 작업 태스크 관리
태스크 원장은 Backlog.md다. 원칙·상태·명령·함정은
`~/MyProject/DevInfra/docs/design/2026-08-30-backlog-md-codex-guide.md`를 따른다.
핵심: 태스크는 줄 번호가 아니라 **ID**로 가리킨다. 차단은 상태가 아니라 `dependencies`다.
```

## §10. 붙었는지 검증 — 읽지 말고 돌려서 확인한다

```bash
codex mcp list                        # backlog 항목이 있나
codex mcp get backlog                 # 명령이 `backlog mcp start` 인가
cd <리포> && backlog task list         # 경고 없이 목록이 나오나
backlog config get statuses           # Awaiting Decision 이 있나
```

`codex doctor`로 설치·설정·런타임 건강도를 함께 볼 수 있다.

## §11. 배선 실측 결과 (2026-08-30 — 실제로 등록하고 확인함)

`codex mcp add backlog -- backlog mcp start` 실행 결과:

- 출력이 **`Added global MCP server 'backlog'`** — Codex 자신이 "global"이라고 말한다(§2의 추론이 사실로 확정).
- `~/.codex/config.toml`이 65줄 → 69줄. 추가된 것은 **정확히 4줄**:

  ```toml
  [mcp_servers.backlog]
  command = "backlog"
  args = ["mcp", "start"]
  ```

- `codex mcp list` → `backlog | backlog | mcp start | enabled`. `cwd`가 `-`이므로 **작업 디렉터리에서 루트를 찾는다.**
- 제거는 `codex mcp remove backlog` 한 줄이다.

### stdio 핸드셰이크로 확인한 서버 실체

`initialize` → `tools/list`를 직접 흘려보낸 결과:

- `serverInfo`: **`backlog.md` 1.50.1**, capabilities `tools` · `resources` · `prompts` · `logging`
- 서버가 세션 시작 지침을 스스로 준다: *"At the beginning of each session, list the available resources and
  read the first one to understand how to use Backlog.md for task management."*
- **`Awaiting Decision`이 `task_create`의 status enum에 실제로 들어 있다** →
  `backlog/config.yml` 수정이 에이전트 인터페이스까지 전달되는 것을 확인했다.
- enum에 **`Draft`**도 있다 — `config.yml`의 `statuses`에 없어도 존재하는 내장 상태다.
- 로그 1건: *"Client does not support MCP roots capability, staying in fallback mode."* —
  roots를 광고하지 않는 클라이언트에서는 cwd 기반 폴백으로 동작한다는 뜻이다(내 프로브가 그랬다).

### 노출되는 MCP 툴 20개

| 묶음 | 툴 |
|---|---|
| 지침 | `get_backlog_instructions` (`overview`/`task-creation`/`task-execution`/`task-finalization`) |
| 태스크 | `task_create` · `task_list` · `task_search` · `task_edit` · `task_view` · `task_archive` · `task_complete` |
| 마일스톤 | `milestone_list` · `milestone_add` · `milestone_rename` · `milestone_remove` · `milestone_archive` |
| 완료 정의 | `definition_of_done_defaults_get` · `definition_of_done_defaults_upsert` |
| 문서 | `document_list` · `document_view` · `document_create` · `document_update` · `document_search` |

**`document_*`가 있다는 것에 유의한다.** Backlog.md는 문서도 관리할 수 있지만, **§7의 경계는 그대로다** —
결정·판정 근거는 리포의 `docs/`에 두고 원장에 넣지 않는다. 문서 계층까지 도구로 옮기는 것은
별도 결정 사항이며 아직 검토하지 않았다.

---

_최초 작성: 2026-08-30. Claude Code 쪽 정본은 `~/.claude/rules/task-management.md`이며 원칙은 동일하다 —_
_이 문서는 Codex가 단독으로 읽어도 되도록 원칙을 자기완결적으로 담고, 배선(§2·§3·§9·§10)만 Codex 전용이다._
_명령·옵션·유효값은 이 맥에서 `--help`와 소스로 직접 확인했다._
