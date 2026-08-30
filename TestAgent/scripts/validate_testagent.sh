#!/usr/bin/env bash
set -euo pipefail

testagent_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 금지 문구 검사에서 면제되는 파일 — testagent_dir 기준 **상대 경로 정확 일치**로만 면제한다.
# grep --exclude 는 basename 을 어느 깊이에서든 매치하므로 쓰지 않는다: 하위 어디에든 같은 이름의
# 파일이 있으면 그 파일 전체가 검사 사각지대가 되고, 실제 의존이 그 안에 숨는다.
exempt_tokens_file="scripts/forbidden-tokens.txt"
exempt_mutation_runner="scripts/mutation_test.sh"

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
  local found=0 file rel rc

  # 파일 목록을 find 로 만든다 — grep -R 은 순회 중 만난 심볼릭 링크를 따라가므로,
  # 채택 앱이 TestAgent 하위에 리포 루트 쪽 링크를 두면 스캔이 부모 리포까지 새어 나간다.
  while IFS= read -r file; do
    rel="${file#"$testagent_dir/"}"
    case "$rel" in "$exempt_tokens_file" | "$exempt_mutation_runner") continue ;; esac

    rc=0
    grep -In -F -i -- "$text" "$file" || rc=$?
    case "$rc" in
      0) found=1 ;;
      1) : ;;
      *)
        # grep 은 0=일치, 1=불일치, 2 이상=에러다. 에러를 "위반 없음"으로 읽으면 읽을 수 없는
        # 파일이 조용히 검사에서 빠지고, 이 스크립트는 검사하지 않은 채 PASS 를 출력한다.
        printf 'ERROR: grep failed on %s (rc=%d)\n' "$rel" "$rc" >&2
        exit 2
        ;;
    esac
  done < <(find "$testagent_dir" -type f | LC_ALL=C sort)

  if [ "$found" -eq 1 ]; then
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
# 러너를 지우면 면제 인자가 죽은 설정이 되고, README 가 광고하는 확인 수단이 사라진다.
require_file "scripts/mutation_test.sh"

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
while IFS= read -r raw || [ -n "$raw" ]; do
  # CR 과 앞뒤 공백을 제거한다. CRLF 파일이나 후행 공백이 섞이면 grep -F 가 영원히 불일치하는데
  # token_count 는 그대로여서 아래 가드도 걸러내지 못한다 — 금지 문구 검사 전체가 조용히 사라진다.
  token="$(printf '%s' "$raw" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  case "$token" in '' | '#'*) continue ;; esac
  # 트림 후에도 제어문자가 남으면 같은 방식으로 조용히 불일치한다 — 통과시키지 않고 거부한다.
  case "$token" in
    *[![:print:]]*)
      printf 'FAIL: forbidden token has non-printable characters\n' >&2
      exit 1
      ;;
  esac
  token_count=$((token_count + 1))
  reject_text "$token"
done < "$testagent_dir/$exempt_tokens_file"

# 목록이 주석만 남으면 금지 문구 검사가 조용히 0건이 된다 — 파일이 비어있지 않다는 것만으로는 부족하다.
test "$token_count" -ge 1 || {
  printf 'FAIL: %s has no token to check\n' "$exempt_tokens_file" >&2
  exit 1
}

printf 'PASS: TestAgent contract is agent-neutral and reusable.\n'
