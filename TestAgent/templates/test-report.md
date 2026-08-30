# TestAgent 실행 결과 — <대상 앱 / 기능 / run-id>

관련 태스크: `<TASK-ID>`  
실행일: `<YYYY-MM-DD HH:MM TZ>`  
판정: `PASS | FAIL | BLOCKED | ERROR`

## 실행 맥락

| 항목 | 값 |
| --- | --- |
| 실행 표면 | `<일반 셸 / Orca / tmux / subagent>` |
| Runner | `<파일 또는 명령>` |
| 격리 자원 | `<이름만, 비밀 제외>` |
| 테스트 사용자 | `<fixture 식별자>` |
| 코드/환경 버전 | `<commit 또는 build version>` |

## 시나리오 결과

| ID | 판정 | 직접 확인한 산출물 | 실패/차이 | 재현 명령 또는 조작 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

## 증거

- 종료 코드:
- API/UI/DB/파일 검증:
- 로그·스크린샷·artifact 경로:
- 비밀/개인정보 마스킹 확인:

## Cleanup

| 항목 | 결과 | 확인 방법 |
| --- | --- | --- |
| 테스트 사용자/데이터 |  |  |
| 임시 파일·세션·queue |  |  |
| 비용 예약·외부 호출 |  |  |
| tmux TestAgent 세션 |  |  |
| Orca TestAgent 터미널 |  |  |

## 후속 조치

- `PASS`: 
- `FAIL`: 대상 버그/태스크 `<TASK-ID>`
- `BLOCKED`: 필요한 결정 또는 dependency
- `ERROR`: 테스트 환경 복구 작업
