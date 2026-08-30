#!/usr/bin/env bash
set -euo pipefail

testagent_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_file() {
  local file="$1"
  test -s "$testagent_dir/$file" || {
    printf 'FAIL: missing or empty %s\n' "$file" >&2
    exit 1
  }
}

require_text() {
  local file="$1"
  local text="$2"
  grep -Fq -- "$text" "$testagent_dir/$file" || {
    printf 'FAIL: %s must contain %s\n' "$file" "$text" >&2
    exit 1
  }
}

reject_text() {
  local text="$1"
  if grep -RFn --include='*.md' -- "$text" "$testagent_dir"; then
    printf 'FAIL: TestAgent must not depend on %s\n' "$text" >&2
    exit 1
  fi
}

require_file "README.md"
require_file "TEST_AGENT.md"
require_file "templates/test-plan.md"
require_file "templates/scenario-matrix.md"
require_file "templates/test-report.md"

require_text "README.md" "Codex와 Claude"
require_text "TEST_AGENT.md" "입력 채널"
require_text "TEST_AGENT.md" "runner 식별자"
require_text "TEST_AGENT.md" "출력 수집"
require_text "TEST_AGENT.md" "완료 신호"
require_text "TEST_AGENT.md" "테스트 실행 표면 정리"
require_text "TEST_AGENT.md" "TestAgent가 만들지 않은 세션"
require_text "templates/test-plan.md" "실행 어댑터 계약"
require_text "templates/test-plan.md" "실행 표면 정리 계획"

reject_text "AGENTS.md"
reject_text "CLAUDE.md"
reject_text "callback"

printf 'PASS: TestAgent contract is agent-neutral and reusable.\n'
