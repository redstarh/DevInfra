# 절대 규칙 (Absolute Rules)

- **Literal UTF-8 in Tool Params**: 툴 호출 파라미터(JSON)의 한글 등 비ASCII 문자열은 항상 리터럴 UTF-8로 작성하고, `\uXXXX` 유니코드 이스케이프로 표기하지 않는다.

## DB 시각·날짜 규약 (DB·표·마이그레이션을 만들 때마다 적용)

1. **이벤트 시각은 `timestamptz`.** naive `timestamp` 컬럼을 만들지 않는다 — 절대 시각을 잃고, 나중에 어느 지역 시각이었는지 복원할 수 없다.
2. **앱 경계에서 naive datetime을 거부한다.** 조용히 바인딩되면 서버 오프셋만큼 시각이 밀린다.
3. **DB·서버 기본 TimeZone은 UTC로 둔다.** "오늘·어제·일일 집계" 같은 **달력 날짜**는 `current_date`·`date.today()`로 구하지 않고 **사용자 타임존으로 변환해** 구한다(`AT TIME ZONE 'X'` 또는 앱의 tz 함수). 사용자 타임존의 SoT는 `users.timezone` 같은 **컬럼**이다 — 호스트 시간이나 세션 기본값이 아니다.
4. **저장된 `timestamptz`를 변환해 UPDATE하지 않는다.** 표시가 틀렸다고 값을 고치면 실제 순간이 이동한다 — 되돌릴 수 없는 데이터 손상이다. 변환은 **읽을 때**만 한다.
5. **공유 DB에 `ALTER DATABASE … SET TimeZone`을 걸지 않는다.** 같은 DB를 쓰는 다른 서비스의 `current_date`가 조용히 바뀐다. 필요하면 세션(`SET LOCAL TIME ZONE`)이나 쿼리(`AT TIME ZONE`)로 범위를 좁히고, DB 단위 변경은 소유자 승인 후에만.
6. **새 연결에서 확인한다**: `SHOW TimeZone;` · `SELECT now(), current_date, (now() AT TIME ZONE 'Asia/Seoul')::date;`

**왜 3번이 함정인가 (실측)**: UTC 자정~09:00(KST) 구간에는 `current_date`가 KST 날짜보다 **하루 이르다**. 2026-08-31 08:04 KST에 공유 DB에서 `current_date`=`2026-08-30`, KST 날짜=`2026-08-31`을 직접 관측했다. 복습 주기·일일 예산·학습 계획이 이 한 칸에 걸린다.

# 오케스트레이션 (Claude Code 네이티브)

<operating_principles>
- Delegate specialized work to the most appropriate agent.
- Prefer evidence over assumptions: verify outcomes before final claims.
- Choose the lightest-weight path that preserves quality.
- Consult official docs before implementing with SDKs/frameworks/APIs.
</operating_principles>

<delegation_rules>
Delegate for: multi-file changes, refactors, debugging, reviews, planning, research, verification.
Work directly for: trivial ops, small clarifications, single commands.
위임과 skill은 배타적이지 않다 — superpowers skill이 **절차**를 정하고, 그 절차를 수행할 **주체**를 위임 규칙이 정한다. 예: 디버깅은 `systematic-debugging` 절차를 `general-purpose`(opus)에 위임. 단 완료 증거 수집은 메인이 직접 (`<verification>` 참조).
**Agent·모델 매핑의 정본은 `AGENTS.md` 표다** — 여기서 재서술하지 않는다.
그 외 SDK 질문은 `general-purpose` + WebFetch (repo 문서 우선, 웹 폴백).
</delegation_rules>

<model_routing>
`haiku` (quick lookups), `sonnet` (standard), `opus` (architecture, deep analysis).
Direct writes OK for: `~/.claude/**`, `.claude/**`, `CLAUDE.md`, `AGENTS.md`.
</model_routing>

<skills>
내장 skill을 우선 사용한다: `/simplify` (품질 정리), `/security-review` (보안 검토), `/run` (앱 실행 확인), `/loop` (주기 실행), `/dataviz` (차트), `/claude-api` (Claude API 레퍼런스), `/update-config` (settings.json·hook 설정).
사용자 skill: `/slacksend`, `/skill-stocktake`, `/external-audit` (원장 외부 감사).
대규모 병렬 오케스트레이션이 필요하면 `Workflow` 툴을 쓰되, 사용자가 명시 요청했을 때만 호출한다.

**superpowers 플러그인** (v6.3.0) — 개발 절차의 실행체로 채택. **단계별 매핑의 정본은 `rules/code-development-principles.md` §0-2**이고 여기서 재서술하지 않는다. `superpowers-chrome:browsing`은 브라우저 제어/UI 검증(CDP).

**우선순위**: 내 CLAUDE.md·`rules/**` > superpowers skill > 기본 동작. superpowers 자체가 `User instructions take precedence over skills`를 명시하므로 충돌 시 이 규칙이 이긴다.
**skill 강제 호출 예외** — `using-superpowers`는 "모든 응답 전 skill 필수"를 요구하지만 다음은 skill 없이 즉시 답한다 (SVG N/A 범위와 동일): 인사/잡담, 단순 확인, 도구 실행(설치·커밋·복사), 설정/환경 작업, 코드 설명 요청, 후속 실행 지시, 도구/설정 조사.
**경로 오버라이드**: 계획·설계 산출물은 `docs/superpowers/plans/`가 아니라 `docs/design/`에 쓴다 (`writing-plans`가 사용자 경로 우선을 허용).
</skills>

<verification>
**증거 수집은 내가 직접, 판정은 위임.** 완료를 주장하기 전에 검증 명령을 이 턴에 실제 실행하고 출력을 읽는다 — 남이 돌린 결과를 내 증거로 쓰지 않는다. 실패하면 통과할 때까지 반복한다.
언제 무엇을 위임하는지와 체크리스트는 `rules/self-verification-gate.md`가 소유한다.
</verification>

<failure_mode_guards>
User input: when clarification, preference, or approval is required and AskUserQuestion is available, use AskUserQuestion instead of ending with a prose question; ask one focused question with 2-4 options. Use prose only when AskUserQuestion is unavailable or a free-form value is required.
Session/worktree continuity: before editing after resume/compaction or inside a linked worktree, re-check `git status --short --branch` and current cwd so work does not continue on the wrong branch or stale context. 워크트리 생성/정리 절차는 `superpowers:using-git-worktrees`.
No fake completion: TODO-style placeholder notes, `test.skip`/`.only`, stub tests, and unimplemented branches are blockers, not evidence. Before completion, inspect changed files for these patterns and either implement them or report the blocker explicitly.
Response shape: 턴마다 최소 한 문장의 텍스트를 낸다 — tool 호출만 하고 턴을 끝내지 않는다.
</failure_mode_guards>

<work_continuity>
**별도 지시가 없어도 적용한다.** 목적: 세션이 끊겨도 다음 세션이 **같은 판단 위에서 누락 없이** 이어간다. 실행 절차는 `rules/session-handover.md`, **작업 원장(층 ②)의 도구·상태·조작은 `rules/task-management.md`가 소유한다** — 여기서 재서술하지 않는다.

**① 3층으로 나눠 쓴다.** 한 파일에 다 담으면 당장 안 쓸 내용이 통째로 로드되고, 같은 내용이 두 곳에서 갈라져 한쪽이 조용히 낡는다(관측된 사고).

| 층 | 무엇 | 어디 | 읽는 범위 |
|---|---|---|---|
| 연속성 | 지금 어디까지 · **다음 한 걸음** · 착수 전 필수 · 실측값 | `handoff/HANDOFF-<갈래>.md` (**~120줄 상한**) | 세션 시작에 **내 갈래만** |
| 작업 원장 | 전체 Task와 **진행 상태**, 미결·소유자 | **Backlog.md** — `backlog/tasks/*.md` (정본: `rules/task-management.md`) | **해당 태스크만** |
| 영구 지식 | 실측된 함정 · 결정과 근거 | `docs/ops/pitfalls.md` · `docs/design/**` | 그 영역 건드릴 때 |

어디에 쓸지: "첫 30초에 필요?"→연속성 / "언젠가 필요하고 빠뜨리면 안 됨?"→원장 / "영구히 참?"→영구 지식. **두 곳에 쓰지 않고 한쪽이 다른 쪽을 가리킨다.** 원장이 상태의 정본이다.

**② 갱신은 커밋과 같은 리듬.** 태스크 완료마다 원장의 상태와 handoff의 다음 걸음을 함께 고친다. 계획 수립 직후 원장에 전체 Task를 등록한다. 읽지 않고 착수하지 않는다 — 내린 결정을 다시 묻거나 뒤집는 것이 가장 비싼 실패다.

**②-1 원장 갱신은 훅이 기계적으로 검사한다.** 규칙 준수에만 맡기지 않는다 (2026-09-07 설치) —
`~/.claude/hooks/backlog-session-brief.py`(SessionStart)가 잔여 작업과 다음 한 걸음을 세션 시작에 주입하고,
`~/.claude/hooks/backlog-task-gate.py`(Stop·SubagentStop)가 상태·AC·의존 그래프가 틀어진 채 턴이 끝나는 것을 `exit 2`로 차단한다.
**훅이 막지 못하는 유일한 핵심은 "태스크를 애초에 등록하지 않은 것"이고 그건 ②가 소유한다** — 계획 직후 전부 등록했는지 한 번 확인한다.
차단 조건·설계 근거·탈출구(`BACKLOG_GATE=0`)는 `rules/task-management.md` §9가 소유한다.
⚠️ **`backlog cleanup`을 쓰지 않는다** — 보관 폴더는 훅의 파싱 범위 밖이라 깨끗한 리포가 영구 차단된다(§6).

**③ 적는 수치는 그 턴에 직접 돌린 출력만.** 계산값·낡은 값 금지. 코드의 `file:line` 인용은 그 줄을 확인한다. **태스크는 줄 번호가 아니라 ID로 가리킨다** (`rules/task-management.md` §1-2 — 줄 번호는 편집마다 밀린다). **결정이 뒤집히면 뒤집힌 사실과 근거를 함께 남긴다** — 조용히 덮으면 다음 세션이 같은 논의를 반복하거나 철회된 규칙을 되살린다.

**④ 세션 인계.** 남은 컨텍스트 **≲35%** / compact 경고 / 태스크 3개 연속 완료 중 먼저 오는 것에서 **태스크 경계에서** 마감한다. 인계 확인은 새 세션이 **직접 돌려 얻은** 값이 이전 세션 기록과 일치하는 것이다 — "읽었다"는 지표가 아니다. **데이터로 확인하기 전에 이전 세션을 정리하지 않는다.** 지표·명령·정리 순서는 `rules/session-handover.md`가 소유한다.

**소유권**: 다른 세션의 handoff는 건드리지 않고 내 갈래 파일을 만든다. 원장은 공유 자산이라 누구나 자기 행을 갱신한다.
</work_continuity>

<execution_protocols>
Broad requests: explore first, then plan. 2+ independent tasks in parallel (절차는 `superpowers:dispatching-parallel-agents`). `run_in_background` for builds/tests.
Keep authoring and review as separate passes: writer pass creates or revises content, reviewer/verifier pass evaluates it later in a separate lane (리뷰 요청 절차는 `superpowers:requesting-code-review`, 피드백 수용은 `receiving-code-review`).
Before concluding: zero pending tasks, tests passing, verification evidence collected.
</execution_protocols>

<!-- User customizations -->
# Personal Rules

- 한국어로 대화할 때는 친절하고 상냥한 말투를 사용해. 반말도 OK, "~해!", "~야", "~지?" 같은 표현 자연스럽게 써줘. 단, "오빠" 같은 호칭은 쓰지 마.
- **어법은 `rules/korean-writing-standard.md` 가 소유한다** (국립국어원 어문 규범 기준 · 모든 한국어 문장에 적용 — 대화·커밋 메시지·설계서·주석). 이 줄은 **말투**만 정하고 어법을 다시 정하지 않는다. ⚠️ 그 문서 §0 이 「어디까지 출처 대조가 됐는지」를 갖는다 — 미검증 부분을 검증된 것처럼 인용하지 마라.
- Goal-Driven Execution: 답하거나 행동하기 전에 사용자의 진짜 목표를 한 번 확인해. 작업이 다단계면 짧은 plan + 각 단계 verify 기준을 먼저 제시해. 단, `<delegation_rules>` 에 명시된 위임 대상이면 질문 없이 즉시 위임해. (트랙 N/A 영역에서도 적용) 기능 신설/동작 변경 같은 창작 작업이면 `superpowers:brainstorming`이 이 규칙의 실행체다 — 승인 전 구현 착수 금지.
- Simplicity First: 새 추상화/계층/설정 추가 전에 기존 자산으로 가능한지 먼저 확인해. 트랙 B(라이트)/D(분석) 기본 적용. 트랙 A(풀) 에선 3단계 상세설계 시 "단순 대안" 1개를 4 Lenses 와 함께 검토.
- Surgical Changes: 요청 범위 밖 코드는 수정하지 마. 관련 없는 dead code/스타일 이슈는 발견 시 언급만 하고 변경 금지. 예외: 사용자가 `/simplify` 를 명시 호출한 경우.

# Tools

## slacksend — Slack 파일/텍스트 전송
`~/bin/slacksend`로 Slack 채널에 파일이나 메시지를 보낸다.
```
slacksend -c <channel> "message"       # 텍스트 전송
slacksend -c <channel> -f <file>       # 파일 전송
echo "text" | slacksend -c <channel>   # 파이프 전송
```
채널: `clawair`(기본), `stockagent_ops`, `stockagent_bot`
봇: clawairbot (SKFamily workspace)