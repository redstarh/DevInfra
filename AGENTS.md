# Agent Instructions

OMC(oh-my-claudecode) 기반 에이전트 오케스트레이션 환경.
에이전트 카탈로그, 스킬, 팀 파이프라인 상세는 `/oh-my-claudecode:omc-reference` 참조.

## Agent Routing

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| explore | Codebase search | 파일/패턴 탐색 |
| planner | Implementation planning | 복잡한 기능, 리팩토링 계획 |
| architect | System design | 아키텍처 결정, 구조 검토 |
| executor | Task execution | 코드 구현 |
| code-reviewer | Code quality | 코드 작성/수정 후 리뷰 |
| security-reviewer | Vulnerability detection | 보안 민감 코드 |
| critic | Analysis/design verification | 분석/설계 결론 검증 |
| verifier | Completion verification | 작업 완료 확인 |
| test-engineer | Test strategy | TDD, 테스트 작성 |
| debugger | Root-cause analysis | 버그 추적, 디버깅 |
| writer | Documentation | README, API docs |
| designer | UI/UX | 프론트엔드 인터페이스 |

## Orchestration

- 복잡한 요청 → **planner** → **executor**
- 코드 작성 후 → **code-reviewer**
- 분석/설계 결론 → **critic** (SVG gate)
- 보안 민감 코드 → **security-reviewer**
- 독립 작업은 병렬 실행

## Coding Style

- Immutability: 새 객체 생성, 기존 객체 변경 금지
- 파일: 200-400줄 권장, 800줄 상한
- 함수: 50줄 이하
- 에러 핸들링: 모든 레벨에서 처리, silent swallow 금지
- 입력 검증: 시스템 경계에서 검증

## Git

Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `perf:`, `ci:`
