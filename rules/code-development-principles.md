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

- **Specify**: 요구사항 정의 (WHAT/WHY만, HOW 금지). Given/When/Then 형식 AC.
- **Clarify**: 모호성 체크 → 캡틴 확인 (추측 금지). **공식 문서 미확인으로 추측하여 넘어가기 금지.**

### 1단계: 분석

요구사항과 데이터 기반으로 영향도/오류/개선사항 파악. 처음 한 번 수행, 이후 필요시만.

> **로그 원본을 메인 컨텍스트에 직접 넣지 말 것** — 반드시 bash 전처리 후 요약만 전달.
> 대규모 분석은 subagent에 위임. 프로젝트별 로그 분석 규칙은 해당 프로젝트 `.claude/rules/` 참조.

### 2단계: 구조파악

수정 대상 소스 구조 파악 → 전체 아키텍처 및 설계 방향 선정

### 3단계: 상세설계

전체 소스 구조를 고려한 상세 설계 방안 마련. 산출물: `docs/design/` 설계서 (Acceptance Scenarios 포함)

- **A트랙**: `4 Lenses 검증` 섹션 필수 (`four-lenses-design-review.md` 참조)
- **B트랙**: 해당 관점만 간략 기술

### 4단계: 설계검토

최종 설계안 확정. 산출물: 변경 대상 파일 목록 + 영향 범위.
품질: `four-lenses-design-review.md` + SVG DESIGN gate.

### 5단계: 개발

최종 설계안 기준 구현. 품질: SVG DEVELOPMENT gate (V1~V5).

### 6단계: 테스트 작성

변경 소스 대상 테스트 작성. 품질: SVG TEST gate (T1~T3).

### 7단계: 테스트 수행

테스트 전체 수행. 품질: SVG TEST gate (T4~T5).

### 9단계: 완료/반복

| 구분 | 내용 |
|------|------|
| **반복** | 오류 시 2~7단계 반복 → 오류 없을 때까지 |
| **simplify** | A/B 트랙만: commit 전 `/simplify` 실행. 수정 있으면 7단계 재실행. |
| **commit** | conventional commits (`feat:`, `fix:`, `refactor:` 등) |
| **리뷰** | 리뷰 요청 → Approve 전 Done 전환 금지. 기준: `common/code-review.md` |

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
- 예외: 소규모(에러 5건 이하)면 세션 분리 없이 진행 가능

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
| 0 Specify | 요구분석 | opus | - | - | - |
| 1 분석 | `Explore` → 분석 | opus | - | `documentSymbol`, `findReferences` | O |
| 2 구조파악 | `Explore` → `Plan` | - | - | `documentSymbol`, `workspaceSymbol` | O |
| 3 상세설계 | `Plan` | - | - | `findReferences` (영향도) | - |
| 4 설계검토 | critic → `Plan` | opus | - | `findReferences` (교차검증) | - |
| 5 개발 | 구현 | sonnet/opus | - | `goToDefinition`, `ty check` | O |
| 6 테스트 | 테스트 작성 | sonnet | - | `documentSymbol` | O |
| 7 테스트수행 | verifier, 디버깅(실패시) | sonnet/opus | - | `ty check` | - |
| 9 완료 | code-reviewer → verifier → 커밋 | opus | `/simplify`, `/security-review` | `ty check` (self-check) | - |

**병렬 규칙**: 독립 파일/모듈은 병렬 실행. 이전 단계 결과 의존 시 순차.

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

_최종 수정: 2026-05-01 — §2 GitHub Actions [skip ci] 규칙 추가 (CI 비용 절감 SoP 연동)_
_이전: 2026-04-13 — 중복 제거 (SubAgent/Skill은 CLAUDE.md 참조), 프로젝트 전용 규칙은 각 프로젝트 .claude/rules/ 분리_
