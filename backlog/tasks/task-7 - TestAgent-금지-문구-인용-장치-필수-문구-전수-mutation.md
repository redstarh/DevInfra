---
id: TASK-7
title: TestAgent 금지 문구 인용 장치 + 필수 문구 전수 mutation
status: To Do
assignee: []
created_date: '2026-08-30 06:09'
labels: []
dependencies: []
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
코드 리뷰 I5·m5 후속. 현재 규약 문서는 금지 문구를 설명 목적으로도 인용할 수 없다 — TASK-6 은 validation 문서의 표현을 바꾸는 방식으로 AC 를 충족했고, 구분 장치는 없다. 그 결과 TEST_AGENT.md 는 '특정 지침 파일명에 의존하지 않는다' 는 해설을 리터럴과 함께 쓸 수 없고, 채택 앱이 TestAgent 사본 안에 자기 에이전트 지침 파일명을 적은 run 기록을 남기면 원인 안내 없이 실패한다. 또한 필수 문구 단정 전수가 mutation 으로 덮이지 않아 커버리지가 범주 단위다. 근거: TestAgent/validation/2026-08-30-cross-agent-validation.md 후속 조치.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 규약 문서가 금지 문구를 설명 목적으로 인용할 수 있는 장치를 도입한다 (줄 단위 pragma 또는 allowlist)
- [ ] #2 그 장치가 실제 의존을 숨기지 않음을 역-mutation 으로 증명한다
- [ ] #3 필수 문구 단정 전수에 대응하는 mutation 케이스를 갖춘다
- [ ] #4 채택 앱이 자기 에이전트 지침 파일명을 run 기록에 적어도 원인 안내와 함께 처리된다
<!-- AC:END -->
