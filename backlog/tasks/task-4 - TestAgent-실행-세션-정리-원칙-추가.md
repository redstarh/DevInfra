---
id: TASK-4
title: TestAgent 실행 세션 정리 원칙 추가
status: Done
assignee: []
created_date: '2026-08-30 04:52'
updated_date: '2026-08-30 04:52'
labels: []
dependencies: []
documentation:
  - TestAgent/TEST_AGENT.md
modified_files:
  - TestAgent/TEST_AGENT.md
  - TestAgent/templates/test-plan.md
  - TestAgent/templates/test-report.md
  - TestAgent/scripts/validate_testagent.sh
priority: high
type: docs
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TestAgent가 만든 tmux 세션과 Orca 테스트 터미널을 결과 수집 뒤 정리하고, 기존 사용자 세션·workspace는 보존하도록 운영 계약·템플릿·self-validation에 반영한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 tmux와 Orca 테스트 실행 표면의 생성·증거 수집·정리 규칙을 운영 계약에 추가한다.
- [x] #2 사용자 소유 세션과 TestAgent가 만든 세션을 구분하는 안전 경계를 명시한다.
- [x] #3 테스트 계획·결과 템플릿에 실행 표면 정리 항목을 추가한다.
- [x] #4 self-validation runner와 문서 검증을 통과한다.
<!-- AC:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: Codex
created: 2026-08-30 04:52
---
기본 정책은 일회성 테스트 실행 표면 정리다. 정리 실패·timeout·중단도 PASS로 끝내지 않고 정리 상태를 결과에 남긴다.
---
<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
TestAgent가 만든 tmux 세션과 Orca 테스트 terminal을 증거 수집 뒤 정확한 식별자로 정리하도록 운영 계약을 추가했다. 기존 사용자 세션·pane·terminal·workspace는 보존하며, 유지 예외는 소유자·목적·종료 조건을 기록한다. self-validation runner가 갱신된 계약을 통과했다.
<!-- SECTION:FINAL_SUMMARY:END -->
