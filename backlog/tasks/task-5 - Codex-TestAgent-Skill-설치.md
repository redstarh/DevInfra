---
id: TASK-5
title: Codex TestAgent Skill 설치
status: Done
assignee: []
created_date: '2026-08-30 05:00'
updated_date: '2026-08-30 05:01'
labels: []
dependencies: []
documentation:
  - TestAgent/TEST_AGENT.md
priority: high
type: docs
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
DevInfra/TestAgent 운영 계약을 Codex가 지속적으로 사용할 수 있는 전역 testagent Skill로 설치한다. 사용자 역할 테스트, 독립 runner, 직접 산출물 검증, 실행 표면 정리 원칙을 적용한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Codex 전역 skills 경로에 유효한 testagent Skill 구조를 만든다.
- [x] #2 Skill이 DevInfra TestAgent 운영 계약을 정본으로 참조하고 핵심 안전 경계를 반영한다.
- [x] #3 Skill을 테스트 요청에 적합하게 발견할 수 있는 설명과 트리거를 작성한다.
- [x] #4 Skill 구조와 frontmatter를 검증한다.
<!-- AC:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: Codex
created: 2026-08-30 05:01
---
자동 호출은 기본 허용 상태다. 이후  또는 사용자 역할 테스트·독립 runner·교차 표면 검증 요청에서 사용한다.
---
<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Codex 전역 skills 경로에 /Users/redstar/.codex/skills/testagent Skill을 설치했다. Skill은 DevInfra/TestAgent 운영 계약을 정본으로 참조하고, 독립 사용자 역할 검증·직접 증거·격리·tmux/Orca 정리 원칙을 적용한다. 기존 En-Coach 가상환경의 PyYAML로 quick_validate.py를 실행해 Skill is valid!를 확인했다.
<!-- SECTION:FINAL_SUMMARY:END -->
