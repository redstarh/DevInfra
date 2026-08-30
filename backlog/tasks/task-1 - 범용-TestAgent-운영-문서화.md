---
id: TASK-1
title: 범용 TestAgent 운영 문서화
status: Done
assignee: []
created_date: '2026-08-30 04:43'
updated_date: '2026-08-30 04:45'
labels: []
dependencies: []
documentation:
  - docs/design/2026-08-30-backlog-md-codex-guide.md
modified_files:
  - README.md
  - TestAgent/README.md
  - TestAgent/TEST_AGENT.md
  - TestAgent/templates/test-plan.md
  - TestAgent/templates/scenario-matrix.md
  - TestAgent/templates/test-report.md
priority: high
type: docs
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
En-Coach, OhMyEnglish, WSEAgent 등 여러 애플리케이션에서 공통으로 쓰는 독립 사용자 역할 테스트 에이전트의 원칙, 역할, 실행 방식, Orca·일반 셸·tmux 어댑터와 재사용 템플릿을 DevInfra/TestAgent에 정리한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 TestAgent의 목적, 권한 경계, 역할 분리를 문서화한다.
- [x] #2 실행 원칙과 증거·격리·정리 규칙을 문서화한다.
- [x] #3 Orca, 일반 셸, 새 tmux 세션의 실행 어댑터를 문서화한다.
- [x] #4 다른 앱이 복사·참조할 수 있는 테스트 계획과 결과 보고서 템플릿을 제공한다.
- [x] #5 문서 구조와 링크를 검증하고 완료 요약을 기록한다.
<!-- AC:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: Codex
created: 2026-08-30 04:44
---
다른 앱은 TestAgent/TEST_AGENT.md를 운영 규약으로 참조하고, templates를 해당 앱 저장소로 복사해 run별 계획과 결과를 남긴다.
---

<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
DevInfra/TestAgent에 범용 TestAgent 운영 계약, 실행 표면(일반 셸·Orca·tmux) 어댑터, 안전·증거·cleanup 원칙과 앱별 테스트 계획·시나리오·결과 템플릿을 추가했다. git diff --check 및 문서 파일 존재·구조를 검증했다.
<!-- SECTION:FINAL_SUMMARY:END -->
