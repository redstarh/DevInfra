---
id: TASK-2
title: TestAgent 에이전트 도구 중립화
status: Done
assignee: []
created_date: '2026-08-30 04:46'
updated_date: '2026-08-30 04:46'
labels: []
dependencies: []
documentation:
  - TestAgent/TEST_AGENT.md
modified_files:
  - TestAgent/README.md
  - TestAgent/TEST_AGENT.md
priority: high
type: docs
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TestAgent 운영 문서를 Codex, Claude 등 특정 코딩 에이전트나 지침 파일명에 종속되지 않도록 일반화한다. runner 입력·식별·출력·완료 신호 계약을 명시한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 특정 에이전트 전용 용어와 절차를 식별한다.
- [x] #2 TestAgent의 지속 사용 규칙을 도구 중립 지침 참조 방식으로 바꾼다.
- [x] #3 실행 표면의 입력·식별·출력·완료 신호를 일반 계약으로 문서화한다.
- [x] #4 문서에서 특정 에이전트 이름에 의존하지 않는지 검증한다.
<!-- AC:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: Codex
created: 2026-08-30 04:46
---
검증: TestAgent 문서에서 Claude, Codex, AGENTS.md, CLAUDE.md, callback 의존 표기가 없는지 확인했다.
---

author: Codex
created: 2026-08-30 04:46
---
요청 취지를 반영해, 특정 이름을 배제하는 대신 Codex와 Claude 모두에 적용되는 공통 계약임을 문서에 명시한다.
---

author: Codex
created: 2026-08-30 04:46
---
Codex와 Claude 모두에 적용되는 공통 원칙임을 문서 첫머리와 도구 중립 계약에 명시했다.
---
<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
TestAgent가 Codex와 Claude를 포함한 여러 코딩 에이전트에서 공통으로 쓰는 원칙임을 명시했다. 공통 계약은 입력 채널, runner 식별자, 출력 수집, 완료 신호이며 각 도구는 이를 구현하는 어댑터로만 다룬다.
<!-- SECTION:FINAL_SUMMARY:END -->
