# TestAgent

Codex와 Claude를 포함한 여러 코딩 에이전트·애플리케이션에서 공통으로 쓰는
**독립 사용자 역할 테스트 에이전트** 운영 자산이다.

TestAgent는 구현 담당 에이전트와 분리된 실행 환경에서 실제 사용자 흐름을 재현하고, 화면 설명이나
에이전트의 자기 보고가 아니라 API·DB·파일·UI 상태 등 **직접 관측 가능한 산출물**로 판정한다.
En-Coach·OhMyEnglish·WSEAgent처럼 기술 스택이 다른 프로젝트에도 적용할 수 있다.
어떤 에이전트를 사용하든 TestAgent의 사용자 역할, 직접 산출물 검증, 격리, cleanup 원칙은 같다.

## 시작 방법

1. 대상 앱의 Acceptance Criteria와 위험 경계를 읽는다.
2. [`templates/test-plan.md`](templates/test-plan.md)를 대상 앱에 복사해 실행 계획을 확정한다.
3. [`templates/scenario-matrix.md`](templates/scenario-matrix.md)로 사용자 역할과 직접 검증 항목을 정한다.
4. [`TEST_AGENT.md`](TEST_AGENT.md)의 실행 규약에 따라 독립 runner를 실행한다.
5. [`templates/test-report.md`](templates/test-report.md)로 명령·관측값·실패 원인·정리 결과를 남긴다.

테스트 계획과 결과는 대상 앱 저장소에 남긴다. 이 폴더는 범용 운영 규약과 템플릿의 정본이며,
앱별 테스트 상태를 보관하는 곳이 아니다.

## TestAgent 자체 검증

문서·템플릿의 공통 계약을 빠르게 확인하려면 아래 runner를 실행한다.

```bash
./TestAgent/scripts/validate_testagent.sh
```

이 검증은 Codex와 Claude 모두에 적용되는 공통 계약, 필수 템플릿, 특정 지침 파일명에 대한
비의존성을 검사한다. 대상 앱의 제품 기능 검증을 대신하지는 않는다.

## 실행 표면 선택

| 표면 | 적합한 경우 | 핵심 확인 |
| --- | --- | --- |
| 일반 셸 | 결정론적 CLI, API, unit/integration runner | 다른 도구에 의존하지 않고 같은 산출물을 검증 |
| Orca 터미널 | 별도 agent runner에 프롬프트를 주입하거나 Orca가 실행 맥락을 관리 | terminal handle로 실행·출력을 읽고, stale handle은 재획득 |
| 새 tmux 세션 | Orca 없이 장기/분리 실행 또는 터미널 주입이 필요 | 매 run 새 세션, pane 출력 캡처, 종료 뒤 세션 정리 |
| 코딩 에이전트 subagent | 구현 세션과 같은 도구 안에서 컨텍스트만 분리해 검증 | 종료 코드가 없다 — 보고 전송을 프롬프트에 명시하고, 대기 알림을 완료로 읽지 않는다 |

동일 시나리오를 여러 표면에서 실행하는 목적은 “도구가 성공했다”가 아니라 **테스트의 직접 산출물
판정이 실행 표면에 의존하지 않는지** 확인하는 데 있다.

## 적용 범위

- 사용자 여정, 권한 경계, 저장·동기화, 비동기 Worker, 오류 복구, 운영 안전장치
- API/DB/파일/메시지 큐/UI 중 대상 기능이 실제로 남기는 결과
- 정상·예외·오류 흐름과 cleanup 검증

다음은 TestAgent의 범위가 아니다.

- 요구사항을 새로 결정하거나 모호한 정책을 임의로 확정하는 일
- 운영 데이터·비밀·실사용자 계정에 쓰기 작업을 수행하는 일
- 구현 에이전트의 작업을 대신 수정하는 일

정책 결정이 필요하면 결과를 `Awaiting Decision`으로 보고하고, 구현 결함이면 재현 증거와 함께
대상 앱의 태스크로 넘긴다.
