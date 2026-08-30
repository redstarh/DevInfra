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
  # 대소문자를 무시하고(-i), md 뿐 아니라 스크립트와 비-md 자산까지 검사한다.
  # 제외 2건은 금지 문구를 데이터·주입 재료로 다루는 테스트 자산이다 — 근거는 forbidden-tokens.txt 주석.
  if grep -RIn -F -i \
      --exclude='forbidden-tokens.txt' \
      --exclude='mutation_test.sh' \
      -- "$text" "$testagent_dir"; then
    printf 'FAIL: TestAgent must not depend on %s\n' "$text" >&2
    exit 1
  fi
}

require_file "README.md"
require_file "TEST_AGENT.md"
require_file "templates/test-plan.md"
require_file "templates/scenario-matrix.md"
require_file "templates/test-report.md"
require_file "scripts/forbidden-tokens.txt"

# 템플릿은 존재만으로 통과시키지 않는다 — 계약의 핵심 항목이 실제로 담겨 있는지 본다.
# (test -s 만으로는 1바이트 파일이 통과한다)
require_text "templates/scenario-matrix.md" "직접 검증"
require_text "templates/scenario-matrix.md" "cleanup"
require_text "templates/test-report.md" "PASS | FAIL | BLOCKED | ERROR"
require_text "templates/test-report.md" "## Cleanup"

require_text "README.md" "Codex와 Claude"
require_text "TEST_AGENT.md" "입력 채널"
require_text "TEST_AGENT.md" "runner 식별자"
require_text "TEST_AGENT.md" "출력 수집"
require_text "TEST_AGENT.md" "완료 신호"
require_text "TEST_AGENT.md" "테스트 실행 표면 정리"
require_text "TEST_AGENT.md" "TestAgent가 만들지 않은 세션"
require_text "templates/test-plan.md" "실행 어댑터 계약"
require_text "templates/test-plan.md" "실행 표면 정리 계획"

# 금지 문구는 이 스크립트에 리터럴로 두지 않고 데이터 파일에서 읽는다 —
# 리터럴을 두면 검사 범위에 포함된 이 스크립트 자신이 위반으로 잡힌다.
token_count=0
while IFS= read -r token || [ -n "$token" ]; do
  case "$token" in '' | '#'*) continue ;; esac
  token_count=$((token_count + 1))
  reject_text "$token"
done < "$testagent_dir/scripts/forbidden-tokens.txt"

# 목록이 주석만 남으면 금지 문구 검사가 조용히 0건이 된다 — 파일이 비어있지 않다는 것만으로는 부족하다.
test "$token_count" -ge 1 || {
  printf 'FAIL: scripts/forbidden-tokens.txt has no token to check\n' >&2
  exit 1
}

printf 'PASS: TestAgent contract is agent-neutral and reusable.\n'
