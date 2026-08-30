# Agent Instructions

Claude Code 네이티브 에이전트 기반 오케스트레이션 환경.
사용 가능한 agent 목록은 세션 시작 시 주입되는 agent 카탈로그를 SoT로 삼는다.

## Agent Routing

| 역할 | Agent | 모델 | When to Use |
|------|-------|------|-------------|
| 코드베이스 탐색 | `Explore` | — | 파일/패턴 탐색, 넓은 fan-out 검색 |
| 계획/설계 | `Plan` | — | 복잡한 기능, 리팩토링 계획, 아키텍처 검토 |
| 코드 구현 | `general-purpose` | sonnet (복잡=opus) | 구현, 다중 파일 수정 |
| 코드 리뷰 | `general-purpose` | opus | 코드 작성/수정 후 리뷰 (`ReportFindings` 사용) |
| 보안 검토 | `/security-review` skill | — | 보안 민감 코드 (인증/입력/쿼리/암호) |
| 분석/설계 검증 | `general-purpose` | opus | 분석·설계 결론 독립 검증 (critic 역할) |
| 완료 검증 | `general-purpose` | sonnet | 테스트 적정성, 완료 근거 확인 |
| 독립 사용자 역할 테스트 | `testagent` | opus | 사용자 여정·권한 경계·저장/동기화·cleanup을 직접 산출물로 판정. 쓰기 도구 없음(구현 수정 금지). 규약 정본은 `DevInfra/TestAgent/` |
| 테스트 작성 | `general-purpose` | sonnet | TDD, 단위/통합 테스트 |
| 디버깅 | `general-purpose` | opus | 근본원인 분석, 회귀 추적 |
| 문서 작성 | `general-purpose` | haiku/sonnet | README, API docs |
| Claude API/CC 질문 | `claude-code-guide` | — | Claude Code·Agent SDK·Claude API 사용법 |
| 장기기억 | `hermes` | — | 세션 간 맥락 recall/save |

프로젝트 전용 agent(`ame-*`, `wse-*`)는 각 프로젝트 `.claude/agents/` 정의를 우선한다.

## Orchestration

- 복잡한 요청 → **Plan** → **general-purpose**(구현)
- 코드 작성 후 → **general-purpose(opus)** 리뷰 패스 (작성자와 다른 컨텍스트). 요청 절차·템플릿은 `superpowers:requesting-code-review`(`code-reviewer.md`), 피드백 처리는 `receiving-code-review`
- 계획 실행 → **`superpowers:subagent-driven-development`** (task당 fresh 구현 subagent + task별 리뷰 + 최종 전체 리뷰)
- 독립 작업은 병렬 실행 (한 응답에 여러 Agent 호출)
- **언제 검증을 위임하는지는 `rules/self-verification-gate.md`가 소유한다** — 여기서 재서술하지 않는다

**subagent 컨텍스트 원칙** (superpowers 공통): subagent에 내 세션 히스토리를 물려주지 않는다. 필요한 것만 정확히 구성해 전달한다.

## Coding Style

- Immutability: 새 객체 생성, 기존 객체 변경 금지
- 파일: 200-400줄 권장, 800줄 상한
- 함수: 50줄 이하
- 에러 핸들링: 모든 레벨에서 처리, silent swallow 금지
- 입력 검증: 시스템 경계에서 검증

## Git

Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `perf:`, `ci:`
