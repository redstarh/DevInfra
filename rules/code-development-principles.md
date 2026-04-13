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

ralph 연동: 트랙 자동 판별 → 해당 단계만 반복 (A=2~7, B=2~7, C=5만, D=1만)

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

> Agent 카탈로그와 Skill 목록은 CLAUDE.md `<agent_catalog>`, `<skills>` 참조.
> 아래는 **단계별 매핑**만 정의한다.

| 단계 | SubAgent | Skill | 병렬 |
|------|----------|-------|------|
| 0 Specify | analyst | ralplan / omc-plan | - |
| 1 분석 | explore → analyst | analyze / sciomc | O |
| 2 구조파악 | explore → architect | - | O |
| 3 상세설계 | planner → architect | ralplan --deliberate (고위험) | - |
| 4 설계검토 | critic → architect | - | - |
| 5 개발 | executor / deep-executor, build-fixer | ultrawork / build-fix | O |
| 6 테스트 | test-engineer | tdd / generate-tests | O |
| 7 테스트수행 | verifier, debugger(실패시) | ultraqa | - |
| 9 완료 | code-reviewer → verifier → git-master | code-review / security-review | - |

**병렬 규칙**: 독립 파일/모듈은 병렬 실행. 이전 단계 결과 의존 시 순차.

---

## §1. 공통 코드 규칙

> commit/리뷰 절차는 §0 9단계 참조. Push 전 lint+test 통과(5·7단계) 필수.

- **Push 후**: CI 실패 시 즉시 수정 → 통과까지 반복
- 모든 개발은 DevAgent(Claude Code)를 통해서만 수행
- 작업 완료 = commit + push + 커밋 해시 공유까지
- 모델 ID: `--model opus`, `--model sonnet` 등 Claude 형식만 사용 (**금지:** `--model amazon-bedrock/...`)

---

_최종 수정: 2026-04-13 — 중복 제거 (SubAgent/Skill은 CLAUDE.md 참조), 프로젝트 전용 규칙은 각 프로젝트 .claude/rules/ 분리_
