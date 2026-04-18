# Self-Verification Gate (SVG)

> 품질 게이트 체크리스트 및 적용 범위 정의. 집행은 hook + agent 위임.
> 2026-04-13: 자기검증 → agent 위임 전환. 메인 컨텍스트에서 검증 테이블 생성 금지.

---

## 검증 방식: Agent 위임

> **원칙: author ≠ reviewer.** 동일 컨텍스트에서 작성과 검증을 동시에 하지 않는다.

| 대상 | 검증 Agent | 모델 | 기준 |
|------|-----------|------|------|
| 분석/조사 결론 | `critic` | opus | A1~A5 |
| 설계/방안 제시 | `critic` | opus | D1~D5 + 4 Lenses |
| 코드 구현 | `code-reviewer` | opus | V1~V5 |
| 테스트 | `verifier` | sonnet | T1~T5 |

**위임 규칙:**
- 분석/설계 결론을 사용자에게 전달하기 **전** 반드시 critic agent 호출
- critic에게 해당 Gate Checklist 항목을 전달하여 독립 검증
- 코드 구현 완료 시 code-reviewer agent 호출
- critic/reviewer 판정에 따라 행동 (아래 Critic Gate 참조)

**금지:** 메인 응답에서 검증 테이블(항목|판정|증거)을 직접 생성하지 않는다.

---

## Critic Gate (분석/설계 시 agent 위임)

검증 질문:
1. 각 주장의 증거가 충분한가?
2. 증거가 다른 결론을 지지할 수 있는가?
3. 놓친 시나리오는 없는가?
4. 설계라면: 4 Lenses 관점에서 빈틈은?

| Critic 판정 | 행동 |
|-------------|------|
| **PASS** | 결론 제시 가능 |
| **CHALLENGE** | 보완 → 재검증 → 보완된 결론 제시 |
| **REJECT** | 폐기 → 재분석 → critic 재호출 |

---

## Gate Checklists

### ANALYSIS (원인/영향도/패턴 분석 시)

| # | 항목 | 설명 | 증거 형식 |
|---|------|------|----------|
| A1 | 증거 출처 | 결론의 근거 출처 | `{로그\|DB\|코드\|WAL}: file:line` |
| A2 | 실제 확인 | Read/Grep/Bash 직접 확인 | tool 호출 기록 참조 |
| A3 | 대안 가설 | 틀릴 수 있는 시나리오 1개+ | "만약 X라면 Y도 가능하지만, Z 때문에 배제" |
| A4 | 증거 일관성 | 복수 출처가 동일 결론 지시 | "코드(file:line) + 로그(패턴) + DB(쿼리) 일치" |
| A5 | 확신도 | CONFIRMED/LIKELY/UNCERTAIN | 증거 수 기반 자동 산정 |

### DESIGN (설계안/방안/개선책 시)

| # | 항목 | 설명 | 증거 형식 |
|---|------|------|----------|
| D1 | 분석 근거 | 검증된 분석에 기반 | "ANALYSIS GATE 통과한 결론 참조" |
| D2 | 영향 범위 | 변경 파일 + 의존성 | `lsp_find_references` 결과 (Python), Grep (자유 텍스트) |
| D3 | 4 Lenses | `four-lenses-design-review.md` 전체 적용 | 각 관점별 1줄 이상 |
| D4 | 기존 충돌 | 현재 코드/설정과 충돌 여부 | Read로 확인한 현재 상태 |
| D5 | 설계 약점 | 빈틈 1개+ 식별 | "이 설계의 약점: ..." |

### DEVELOPMENT (코드 작성/수정 시)

| # | 항목 | 설명 | 증거 형식 |
|---|------|------|----------|
| V1 | 설계 기반 | 확정 설계에 따른 구현 | 설계서 참조 또는 사용자 지시 |
| V2 | 방어 로직 | 오류/예외 방어 필수 (null/empty/exception) | 해당 코드 라인 |
| V3 | 컨벤션 | 매직넘버, safe_parse, naive dt | ruff check 결과 + `lsp_diagnostics` 출력 |
| V4 | 의존성 | import, 파라미터 주입 | ruff I001 결과 |
| V5 | lint | ruff check + format 통과 + 타입 오류 0 | 명령 출력 + `lsp_diagnostics` 0건 |

### TEST (테스트 작성/수행 시)

| # | 항목 | 설명 | 증거 형식 |
|---|------|------|----------|
| T1 | 커버리지 | 변경 소스 전체 커버 단위+통합 테스트 필수 | 테스트 파일:함수 목록 + `lsp_document_symbols` 대조 |
| T2 | 엣지케이스 | 경계값, null, empty 필수 포함 | 테스트 케이스 이름 |
| T3 | 실패 시나리오 | 예외/장애 대응 케이스 필수 포함 | 테스트 케이스 이름 |
| T4 | 무회귀 | 기존 테스트 passed 수 유지 또는 증가 필수. 실패 시 단독 실행으로 flaky 여부 구분 | pytest 출력 (before/after) |
| T5 | 실행 | 실제 실행 결과 | pytest 출력 첨부 |

---

## 적용 범위

| 질문 유형 | 게이트 | Agent 위임 |
|----------|--------|-----------|
| 에러/원인 분석 | ANALYSIS | critic(opus) 필수 |
| 설계/방안 제시 | DESIGN | critic(opus) 필수 |
| 코드 구현 | DEVELOPMENT | code-reviewer(opus) 완료 시 |
| 테스트 | TEST | verifier(sonnet) 완료 시 |
| 분석+설계 | ANALYSIS+DESIGN | critic(opus) 필수 |
| 개발+테스트 | DEV+TEST | code-reviewer(opus) + verifier(sonnet) |
| 기능 설명/비교/동작 확인 | ANALYSIS | 경미하면 N/A, 판단 필요시 critic |
| 도구/설정 조사 | N/A | 불필요 |
| subagent 결과 전달 | N/A | 직접 검증 1건 필수 |

### N/A (검증 불필요 — 바로 답변)

1. **인사/잡담** — 정보 전달 없는 응답
2. **단순 확인** — 네/아니오 1문장 (판단 없음)
3. **도구 실행** — 커밋, 업데이트, 설치, 삭제, 파일 복사
4. **설정/환경 작업** — hook 수정, 패키지 설치, 설정 변경
5. **코드 설명 요청** — "이게 뭐야?" 수준 (분석 판단 없음)
6. **후속 실행** — "그거 해줘", "진행해" (이전 분석에 기반한 실행)
7. **도구/설정 조사** — 현재 상태 확인, 버전 체크

### subagent 검증

- 전달 전 **최소 1개 직접 검증**(Read/Grep/Bash) 필수
- 불일치 시 직접 검증 우선, subagent 결과 폐기
