# 개발 원칙 (Code Development Principles)

> **워크플로우 오케스트레이터** — 개발 절차/순서를 정의. 품질 기준은 전문 파일 참조.
> 전문 파일: `self-verification-gate.md`(품질 게이트), `four-lenses-design-review.md`(설계), `common/code-review.md`(리뷰)
> Agent/Skill 카탈로그는 CLAUDE.md 참조. 프로젝트 전용 규칙은 각 프로젝트 `.claude/rules/` 참조.

---

## §0. 통합 개발 절차 — 0~9단계

> SDD(Spec-Driven Development) 채택. 모든 개발 작업은 아래 절차를 준수한다.

### 작업 유형별 트랙 분류

| 트랙 | 대상 | 수행 단계 | 절감 |
|------|------|----------|------|
| **A. 풀 트랙** | 새 기능, 아키텍처 변경 | 0→1→2→3→4→5→6→7→9 (전체) | 기준 |
| **B. 라이트 트랙** | 버그 수정, 설정 변경, 소규모 리팩 | 1→2→5→7→9 | ~50% |
| **C. 문서 트랙** | 규칙/설계서/CLAUDE.md/설정 파일 수정 | 2→5→9 | ~70% |
| **D. 분석 트랙** | 로그 분석, 조사, 리포트 (코드 변경 없음) | 1→9 | ~80% |

TDD(5단계)는 **A·B 트랙만** 적용. C·D 트랙은 대상 아님.

```
트랙 판별:
소스 코드 변경?
  ├─ YES → 새 기능/구조 변경? → YES → A. 풀 트랙
  │                          → NO  → B. 라이트 트랙
  └─ NO  → 분석/조사만?     → YES → D. 분석 트랙
                             → NO  → C. 문서 트랙
```

반복 실행 시: 트랙 판별 후 해당 단계만 반복 (A=2~7, B=2~7, C=5만, D=1만)

### 0단계: Specify + Clarify

**실행체: `superpowers:brainstorming`** — Spike/Bounded/Architectural 3경로 분류 후 승인 게이트. 아래는 그 위에 얹는 우리 요건.

- **Specify**: 요구사항 정의 (WHAT/WHY만, HOW 금지). Given/When/Then 형식 AC.
- **Clarify**: 모호성 체크 → 캡틴 확인 (추측 금지). **공식 문서 미확인으로 추측하여 넘어가기 금지.**
- 캡틴 확인은 `AskUserQuestion` 사용 (CLAUDE.md `<failure_mode_guards>`). brainstorming의 HARD-GATE(승인 없이 구현 금지)를 그대로 적용한다.

### 1단계: 분석

요구사항과 데이터 기반으로 영향도/오류/개선사항 파악. 처음 한 번 수행, 이후 필요시만.

**버그/테스트 실패/예기치 않은 동작이면 `superpowers:systematic-debugging`을 먼저 호출한다** (Iron Law: 근본원인 조사 전 수정 금지). 그 결과 결론에 SVG ANALYSIS gate(A1~A5)를 적용해 critic agent로 검증한다 — 디버깅 절차는 skill, 결론 판정은 SVG.

> **로그 원본을 메인 컨텍스트에 직접 넣지 말 것** — 반드시 bash 전처리 후 요약만 전달.
> 대규모 분석은 subagent에 위임. 프로젝트별 로그 분석 규칙은 해당 프로젝트 `.claude/rules/` 참조.

### 2단계: 구조파악

수정 대상 소스 구조 파악 → 전체 아키텍처 및 설계 방향 선정

### 3단계: 상세설계

**실행체: `superpowers:writing-plans`** — File Structure → Task Right-Sizing → task별 테스트/커밋 단위.

산출물: `docs/design/` 설계서 (Acceptance Scenarios 포함). ⚠️ **경로 오버라이드** — writing-plans 기본값 `docs/superpowers/plans/YYYY-MM-DD-<name>.md`를 쓰지 말고 `docs/design/`을 쓴다 (skill이 사용자 경로 우선을 허용).

- **A트랙**: `4 Lenses 검증` 섹션 필수 (`four-lenses-design-review.md` 참조)
- **B트랙**: 해당 관점만 간략 기술

### 4단계: 설계검토

최종 설계안 확정. 산출물: 변경 대상 파일 목록 + 영향 범위.
품질: `four-lenses-design-review.md` + SVG DESIGN gate.

### 5단계: 개발 — TDD 사이클

**실행체: `superpowers:test-driven-development`** (red → green → refactor). 계획 실행 방식은 같은 세션이면 `subagent-driven-development`, 별도 세션이면 `executing-plans`.

⚠️ **순서 재정의 (2026-08-19)** — 기존 "5 개발 → 6 테스트 작성" 순서를 **테스트 우선**으로 뒤집는다. 5단계 안에서 실패하는 테스트를 먼저 쓰고 실패를 확인한 뒤 최소 구현으로 통과시킨다. Iron Law: `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`.

- **적용 범위**: A·B 트랙만. C(문서)·D(분석) 트랙은 TDD 대상 아님.
- **예외** (캡틴 확인 필요): 버려질 프로토타입, 생성된 코드, 설정 파일.
- 품질: SVG DEVELOPMENT gate (V1~V5) + TEST gate T0(red-green 증거).

### 6단계: 테스트 보강

5단계 TDD 사이클에서 나오지 않은 것을 채운다 — 엣지케이스/경계값/null·empty(T2), 실패·예외 시나리오(T3), 통합 테스트. 커버리지 대조(T1). 품질: SVG TEST gate (T1~T3).

### 7단계: 테스트 수행

테스트 전체 수행. 품질: SVG TEST gate (T4~T5). 완료 주장 전 `superpowers:verification-before-completion`으로 검증 명령을 직접 실행해 증거를 확보한다.

### 9단계: 완료/반복

| 구분 | 내용 |
|------|------|
| **반복** | 오류 시 2~7단계 반복 → 오류 없을 때까지 |
| **simplify** | A/B 트랙만: commit 전 `/simplify` 실행. 수정 있으면 7단계 재실행. |
| **commit** | conventional commits (`feat:`, `fix:`, `refactor:` 등) |
| **리뷰** | `superpowers:requesting-code-review`로 요청 → `receiving-code-review`로 피드백 처리. Approve 전 Done 전환 금지. 심각도 매핑·판정 기준: `common/code-review.md` |
| **브랜치 정리** | `superpowers:finishing-a-development-branch` — 병합/정리 방식 결정. push·병합은 캡틴 확인 후. |
| **문서 마감** | **작업 원장**에 태스크 상태·미결·소유자를 남기고, handoff에는 다음 한 걸음만 남긴다. 원장 도구(Backlog.md)·상태·조작은 `task-management.md`, 3층 분리 규약은 CLAUDE.md `<work_continuity>`, 세션 인계 절차는 `session-handover.md`. |

---

## §0-1. 토큰 최적화

| 방법 | 효과 | 적용 |
|------|------|------|
| 분석을 subagent에 위임 | 메인 컨텍스트 오염 방지 | 1단계 |
| grep에 head_limit 적용 | 결과 5~10줄 제한 | 1~2단계 |
| bash 전처리 스크립트 | 요약 통계 먼저 추출 | 1단계 |
| 분석/개발 세션 분리 | 컨텍스트 폭발 방지 | 대규모 분석 시 |

### 세션 분리 규칙

- 1단계(분석) 완료 시 결과를 파일 저장 → 새 세션에서 2단계부터
- **다음 세션이 로드할 양을 의식한다** — handoff는 짧게(~120줄), 전체 Task·상태는 작업 원장에, 함정·결정은 영구 문서에. 세션 시작에 당장 안 쓸 내용이 통째로 로드되면 컨텍스트를 낭비하고 낡은 내용을 정본으로 오인한다
- 예외: 소규모(에러 5건 이하)면 세션 분리 없이 진행 가능
- **끊기 전에 원장과 handoff를 갱신한다** — 이 절이 *언제 끊을지*를 정하고, CLAUDE.md `<work_continuity>`가 *무엇을 어디에 남길지*, `session-handover.md`가 *어떻게 넘길지*를 정한다. 갱신 시점은 3단계 직후·**각 태스크 완료 직후**·9단계 마감이며 별도 지시를 기다리지 않는다.
- **인계 트리거**: 남은 컨텍스트 ≲35% / compact 경고 / 태스크 3개 연속 완료 중 먼저 오는 것. **태스크 경계에서만** 끊는다 — 반쯤 고친 코드를 넘기지 않는다.

### Continuation 방지

- **1세션 = 1작업 목표** — 이질적 작업 혼합 금지
- continuation 발생 시 → 결과 저장 → `/exit` → 새 세션
- 대형 결과 → subagent에서 생성 → 파일 저장 → 메인은 요약만

### 대형 파일 작성

- Write 1회에 **300줄(~10KB) 이하** 권장
- 300줄 초과: 섹션 분할 또는 subagent 위임
- 큰 파일은 한 번 읽고 요약을 notepad에 기록, 원본 재읽기 금지

---

## §0-2. 단계별 SubAgent/Skill 가이드

> Agent 매핑 상세는 `~/.claude/AGENTS.md`, Skill 목록은 CLAUDE.md `<skills>` 참조.
> 아래는 **단계별 매핑**만 정의한다. 역할명(critic/reviewer 등)은 `general-purpose` agent에 부여하는 프롬프트 역할이다.

| 단계 | SubAgent (역할) | 모델 | Skill | LSP | 병렬 |
|------|----------------|------|-------|-----|------|
| 0 Specify | 요구분석 | opus | `superpowers:brainstorming` | - | - |
| 1 분석 | `Explore` → 분석 | opus | `superpowers:systematic-debugging` (버그 시) | `documentSymbol`, `findReferences` | O |
| 2 구조파악 | `Explore` → `Plan` | - | - | `documentSymbol`, `workspaceSymbol` | O |
| 3 상세설계 | `Plan` | - | `superpowers:writing-plans` (경로는 `docs/design/`) | `findReferences` (영향도) | - |
| 4 설계검토 | critic → `Plan` | opus | - | `findReferences` (교차검증) | - |
| 5 개발 | 구현 | sonnet/opus | `superpowers:test-driven-development` + `subagent-driven-development`(동일 세션) / `executing-plans`(별도 세션) | `goToDefinition`, `ty check` | O |
| 6 테스트 보강 | 테스트 작성 | sonnet | - | `documentSymbol` | O |
| 7 테스트수행 | verifier, 디버깅(실패시) | sonnet/opus | `superpowers:verification-before-completion`, `systematic-debugging`(실패 시) | `ty check` | - |
| 9 완료 | code-reviewer → verifier → 커밋 | opus | `superpowers:requesting-code-review` → `receiving-code-review` → `finishing-a-development-branch`, `/simplify`, `/security-review` | `ty check` (self-check) | - |

**병렬 규칙**: 독립 파일/모듈은 병렬 실행. 이전 단계 결과 의존 시 순차. 절차는 `superpowers:dispatching-parallel-agents`.

**skill vs agent 역할 분리** — superpowers skill은 **절차(how)**를, SVG gate는 **판정(pass/fail)**을 담당한다. skill을 따라 작업한 뒤에도 결론 검증은 별도 agent에 위임한다 (`self-verification-gate.md`). 반대로 skill이 요구하는 "명령 직접 실행해 증거 확보"는 메인이 수행한다 — 위임 대상이 아니다.

**신규 skill 작성**: `superpowers:writing-skills`로 작성 → `/skill-stocktake`로 감사 (작성 ≠ 감사, 별도 패스).

**LSP 우선 원칙** (SoT — 전역 기본):

Python 심볼/참조/정의 추적은 네이티브 `LSP` 툴 우선(서버: `pyright-lsp` 플러그인). Grep은 자유 텍스트(로그/주석/WAL/JSON) 전용.

| 목적 | 1차 도구 | Gate 증거로 허용 |
|------|---------|:----------------:|
| 함수/클래스 호출처 (영향도) | `LSP(findReferences)` | D2, 4L L4 |
| 함수/메서드 정의 | `LSP(goToDefinition)` | V1 |
| 파일 구조 (메서드 트리) | `LSP(documentSymbol)` | - |
| 워크스페이스 심볼 검색 | `LSP(workspaceSymbol)` + `query` | - |
| 타입 시그니처 / 계약 확인 | `LSP(hover)` | 4L L1 |
| 호출 계층 추적 | `LSP(incomingCalls/outgoingCalls)` | 4L L4 |
| 타입 오류/경고 self-check | `ty check` (또는 `pyright`) | V3, V5, T1 (ruff와 병기) |
| 로그/주석/WAL/커밋 | Grep, `git log` | LSP 대상 아님 |

⚠️ 네이티브 `LSP` 툴에는 **diagnostics 연산이 없다** → 타입/린트 진단은 CLI(`ty check`, `.venv/bin/ruff check`)로 수집한다.

**Fallback**: LSP 서버 미기동/타임아웃 시 Grep 2차. `ty` 알파 단계의 엣지케이스(동적 속성, 데코레이터 체인)는 Grep으로 교차 검증 권장.

**범위**: Python 전체 프로젝트. TS/JS는 프로젝트별 `.claude/rules/`에서 별도 정의 (기본값 미정).

**환경 요건**: `ty` (Astral, `pipx install ty`), `pyright-lsp` 플러그인(LSP 서버). 프로젝트 특수성(언어 혼용/경로/예외)은 각 프로젝트 `.claude/rules/` 참조 (예: `StockAgent/.claude/rules/sa-coding.md §10`).

---

## §1. 공통 코드 규칙

> commit/리뷰 절차는 §0 9단계 참조. Push 전 lint+test 통과(5·7단계) 필수.

- **Push 후**: CI 실패 시 즉시 수정 → 통과까지 반복
- 모든 개발은 DevAgent(Claude Code)를 통해서만 수행
- 작업 완료 = commit + push + 커밋 해시 공유까지
- 모델 ID: `--model opus`, `--model sonnet` 등 Claude 형식만 사용 (**금지:** `--model amazon-bedrock/...`)

---

## §2. GitHub Actions `[skip ci]` 사용 규칙

> 2026-05-01: Free plan Private repo 월 2000분 한도 대응. SoP: `~/AgentDev/docs/ops/github-ci-cost-reduction-sop.md`

커밋 메시지에 `[skip ci]` / `[ci skip]` / `[no ci]` 포함 시 GitHub Actions workflow **전체 스킵**됨 (GitHub 공식 지원).

### 허용 (의도적 스킵)
- `docs:` 접두어 커밋 (docs-only 변경)
- `chore(docs):`, `chore(rules):` 접두어
- `.claude/**`, `data/reports/**`, `docs/analysis/**`, `docs/design/**` 전용 커밋

### 절대 금지
- **`feat:` / `fix:` / `perf:` / `refactor:` / `test:`** 접두어 커밋에는 `[skip ci]` 사용 **금지**
- `config.py` 변경 포함 커밋 (Strategy-Config sync check 우회 위험)

### 기본 동작
`.github/workflows/test.yml`의 `paths-ignore`에 명시된 경로(`docs/**`, `.claude/**` 등) 커밋은 **자동 스킵**되므로 `[skip ci]` 태그 **불필요**. 태그는 paths-ignore 범위 외 docs-only 커밋에만 사용.

---

_최종 수정: 2026-08-28 — `<handoff>` → `<work_continuity>`(3층 분리) 개칭, 세션 인계 트리거·절차 연결(`session-handover.md`)._
_이전: 2026-08-27 — handoff 연속성 규칙 연결. 9단계에 "handoff 마감" 행, §0-1 세션 분리 규칙에 갱신 시점 명시. 규약 본문은 CLAUDE.md `<handoff>`(중복 서술 금지)._
_이전: 2026-08-19 — superpowers v6.3.0 통합. 5단계를 TDD(test-first)로 재정의, 6단계는 "테스트 보강"으로 변경. §0-2 Skill 열에 superpowers 매핑._
_이전: 2026-05-01 — §2 GitHub Actions [skip ci] 규칙 추가 (CI 비용 절감 SoP 연동)_
_이전: 2026-04-13 — 중복 제거 (SubAgent/Skill은 CLAUDE.md 참조), 프로젝트 전용 규칙은 각 프로젝트 .claude/rules/ 분리_
