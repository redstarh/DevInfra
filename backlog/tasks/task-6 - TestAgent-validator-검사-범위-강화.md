---
id: TASK-6
title: TestAgent validator 검사 범위 강화
status: To Do
assignee: []
created_date: '2026-08-30 05:16'
labels: []
dependencies: []
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TASK-3 검증에서 validate_testagent.sh 의 사각지대 4건이 mutation 테스트로 확인됐다(근거: TestAgent/validation/2026-08-30-cross-agent-validation.md). require_file 이 test -s 라 1바이트 파일이 통과하고, reject_text 가 대소문자 고정이라 소문자 claude.md 와 대문자 Callback 이 통과하며, --include='*.md' 제한 때문에 비-md 자산과 스크립트 자신이 검사 범위 밖이다. 함정: 대소문자 무시를 그냥 켜면 사각지대를 설명하는 validation 문서 2줄이 false positive 로 잡힌다. 실제 의존과 설명 목적 언급을 구분해야 한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 reject_text 가 대소문자를 무시하고 검사한다
- [ ] #2 사각지대를 설명하는 문서 언급이 실제 의존과 구분되어 false positive 로 잡히지 않는다
- [ ] #3 필수 템플릿에 내용 단정을 추가하거나 최소 바이트·행 기준으로 교체해 1바이트 통과를 막는다
- [ ] #4 검사 범위를 스크립트 자신과 비-md 자산까지 확대한다
- [ ] #5 mutation M6·M8·M9·M10 이 exit 1 로 떨어지고 원본 트리는 PASS 를 유지하는 것을 실행 출력으로 확인한다
<!-- AC:END -->
