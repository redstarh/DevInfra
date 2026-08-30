#!/usr/bin/env bash
# validate_testagent.sh 의 검사 강도를 mutation 으로 확인한다.
#
# 원본 트리는 절대 수정하지 않는다 — 부모 임시 디렉터리 하나를 만들고 케이스마다 그 안에 사본을 두어
# 거기에만 변형을 적용한 뒤 즉시 지운다. 각 케이스는 "이 변형을 넣으면 validator 가 잡아야 한다"는
# 단정이며, **기대 종료 코드와 기대 FAIL 메시지를 함께** 대조한다. 메시지까지 보는 이유는 fail-fast
# 구조에서 종료 코드만 보면 "의도한 검사가 잡았는지" 아니면 "다른 단정이 먼저 걸렸는지"를 구분할 수
# 없기 때문이다.
#
# ⚠️ 이 파일은 validate_testagent.sh 의 금지 문구 검사에서 면제된다(상대 경로 정확 일치).
#    금지 문구를 주입 재료로 다루는 것이 이 러너의 목적이므로, 검사 대상에 넣으면 아래 리터럴 때문에
#    테스트 자산 자체가 위반으로 잡힌다. 면제 근거는 validate_testagent.sh 의 reject_text 주석에 있다.

set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass=0
fail=0

# 금지 문구 리터럴. 이 파일이 면제 대상인 이유가 이 세 줄이다 — 변수로 둔 것은 가독성 목적이며,
# 면제와는 무관하다(변수에 담아도 grep -F 에는 그대로 걸린다).
guard_upper_a="AGENTS.md"
guard_upper_c="CLAUDE.md"
guard_lower="callback"

work_root=""
cleanup() {
  if [ -n "$work_root" ] && [ -d "$work_root" ]; then
    chmod -R u+rwX "$work_root" 2>/dev/null || :
    rm -rf "$work_root"
  fi
  return 0
}
# 중단·에러 경로에서도 임시 경로를 남기지 않는다 — 남으면 다음 실행이 정리 검사에서 실패한다.
trap cleanup EXIT INT TERM

work_root="$(mktemp -d "${TMPDIR:-/tmp}/testagent-mutation-XXXXXX")"

# 이식성: sed -i 는 BSD 와 GNU 가 문법이 다르다(BSD 는 빈 suffix 를 요구하고 GNU 는 붙여 받는다).
# 임시 파일 경유로 양쪽에서 같게 동작시킨다.
rewrite() {
  local file="$1" expr="$2"
  sed "$expr" "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

apply_mutation() {
  local t="$1" id="$2"
  case "$id" in
    M0)  : ;;
    M1)  rm "$t/templates/test-report.md" ;;
    M2)  : > "$t/templates/scenario-matrix.md" ;;
    M3)  rewrite "$t/TEST_AGENT.md" 's/테스트 실행 표면 정리/뒷정리/g' ;;
    M4)  printf '\n%s 를 읽는다.\n' "$guard_upper_c" >> "$t/README.md" ;;
    M5)  for f in "$t/validation/"*.md; do
           printf '\n%s 에 의존한다.\n' "$guard_upper_a" >> "$f"
           break
         done ;;
    M6)  printf 'x' > "$t/templates/test-report.md" ;;
    M7)  printf '\n%s 으로 완료를 받는다.\n' "$guard_lower" >> "$t/templates/test-plan.md" ;;
    M8)  printf '\n%s 를 읽는다.\n' \
           "$(printf '%s' "$guard_upper_c" | tr 'A-Z' 'a-z')" >> "$t/README.md" ;;
    M9)  printf '\n%s 으로 완료를 받는다.\n' "Callback" >> "$t/TEST_AGENT.md" ;;
    M10) printf '%s 에 의존한다.\n' "$guard_upper_a" > "$t/adapter-notes.txt" ;;
    M11) printf '\n' > "$t/templates/test-plan.md" ;;
    M12) grep '^#' "$t/scripts/forbidden-tokens.txt" > "$t/scripts/tokens.tmp" || :
         mv "$t/scripts/tokens.tmp" "$t/scripts/forbidden-tokens.txt" ;;
    M13) # 토큰 파일을 CRLF 로 바꾸고 실제 위반을 함께 넣는다.
         # CR 을 트림하지 않으면 grep -F 가 불일치해 위반이 조용히 통과한다.
         printf '%s\r\n%s\r\n%s\r\n' "$guard_upper_a" "$guard_upper_c" "$guard_lower" \
           > "$t/scripts/forbidden-tokens.txt"
         printf '\n%s 에 의존한다.\n' "$guard_upper_c" >> "$t/README.md" ;;
    M14) printf '\n%s 를 본다.\n' \
           "$(printf '%s' "$guard_upper_a" | tr 'A-Z' 'a-z')" >> "$t/README.md" ;;
    M15) # 읽을 수 없는 파일. grep 은 rc=2 로 죽는데 이를 "위반 없음"으로 읽으면 조용히 통과한다.
         printf '%s 에 의존한다.\n' "$guard_upper_c" > "$t/unreadable.md"
         chmod 000 "$t/unreadable.md" ;;
    M16) # 면제가 실제로 동작하는지 보는 역-mutation. 면제 파일 안의 의존은 통과해야 한다.
         printf '\n# %s 는 이 파일에서 검사되지 않는다.\n' "$guard_upper_c" \
           >> "$t/scripts/mutation_test.sh" ;;
    M17) # 같은 basename 이지만 다른 경로. basename 면제였다면 숨었을 위반이다.
         mkdir -p "$t/deep/nested"
         printf '%s 에 의존한다.\n' "$guard_upper_c" > "$t/deep/nested/mutation_test.sh" ;;
    M18) rm "$t/scripts/mutation_test.sh" ;;
    *)   printf 'ERROR: unknown mutation %s\n' "$id" >&2; exit 2 ;;
  esac
}

describe() {
  case "$1" in
    M0)  echo "사본 무변형 (기준선)" ;;
    M1)  echo "필수 템플릿 삭제" ;;
    M2)  echo "필수 템플릿 비우기" ;;
    M3)  echo "필수 문구 제거" ;;
    M4)  echo "md 에 금지 문구 주입 (대문자)" ;;
    M5)  echo "validation 하위 md 에 금지 문구 주입" ;;
    M6)  echo "필수 템플릿을 1바이트로 축소" ;;
    M7)  echo "템플릿에 금지 문구 주입 (소문자)" ;;
    M8)  echo "md 에 금지 문구 주입 (소문자 변형)" ;;
    M9)  echo "md 에 금지 문구 주입 (대문자 시작 변형)" ;;
    M10) echo "비-md 자산에 금지 문구 주입" ;;
    M11) echo "필수 템플릿을 개행 1바이트로 축소" ;;
    M12) echo "금지 문구 목록을 주석만 남기고 비우기" ;;
    M13) echo "토큰 파일을 CRLF 로 바꾸고 위반 주입" ;;
    M14) echo "md 에 다른 금지 문구 주입 (소문자 변형)" ;;
    M15) echo "읽을 수 없는 파일에 위반 주입" ;;
    M16) echo "면제 파일 안의 의존은 통과한다 (역-mutation)" ;;
    M17) echo "같은 이름 다른 경로의 파일은 면제되지 않는다" ;;
    M18) echo "mutation 러너 삭제" ;;
  esac
}

# run_case <id> <기대 exit> [기대 FAIL 메시지 일부]
run_case() {
  local id="$1" want="$2" want_msg="${3:-}"
  local desc got=0 w err
  desc="$(describe "$id")"
  w="$work_root/$id"
  mkdir -p "$w"
  cp -R "$src" "$w/TestAgent"
  apply_mutation "$w/TestAgent" "$id"

  # stderr 만 캡처한다 — 어떤 단정이 걸렸는지 귀속하려면 FAIL 메시지가 필요하다.
  err="$("$w/TestAgent/scripts/validate_testagent.sh" 2>&1 >/dev/null)" || got=$?

  chmod -R u+rwX "$w" 2>/dev/null || :
  rm -rf "$w"

  if [ "$got" -ne "$want" ]; then
    printf 'FAIL  %-4s exit=%d (기대 %d)  %s\n' "$id" "$got" "$want" "$desc"
    fail=$((fail + 1))
    return 0
  fi
  if [ -n "$want_msg" ] && ! printf '%s\n' "$err" | grep -Fq -- "$want_msg"; then
    printf 'FAIL  %-4s exit=%d 이나 메시지 귀속 불일치  %s\n' "$id" "$got" "$desc"
    printf '        기대: %s\n' "$want_msg"
    printf '        실제: %s\n' "$(printf '%s\n' "$err" | head -1)"
    fail=$((fail + 1))
    return 0
  fi
  printf 'PASS  %-4s exit=%d  %s\n' "$id" "$got" "$desc"
  pass=$((pass + 1))
  return 0
}

printf '=== mutation test: validate_testagent.sh ===\n'

run_case M0  0
run_case M1  1 "missing or empty templates/test-report.md"
run_case M2  1 "missing or empty templates/scenario-matrix.md"
run_case M3  1 "TEST_AGENT.md must contain 테스트 실행 표면 정리"
run_case M4  1 "must not depend on CLAUDE.md"
run_case M5  1 "must not depend on AGENTS.md"
run_case M6  1 "templates/test-report.md must contain PASS | FAIL | BLOCKED | ERROR"
run_case M7  1 "must not depend on callback"
run_case M8  1 "must not depend on CLAUDE.md"
run_case M9  1 "must not depend on callback"
run_case M10 1 "must not depend on AGENTS.md"
run_case M11 1 "templates/test-plan.md must contain 실행 어댑터 계약"
run_case M12 1 "has no token to check"
run_case M13 1 "must not depend on CLAUDE.md"
run_case M14 1 "must not depend on AGENTS.md"
run_case M15 2 "grep failed on unreadable.md"
run_case M16 0
run_case M17 1 "must not depend on CLAUDE.md"
run_case M18 1 "missing or empty scripts/mutation_test.sh"

printf -- '--- %d passed, %d failed ---\n' "$pass" "$fail"

# 원본 트리가 오염되지 않았는지 확인한다.
for stray in adapter-notes.txt unreadable.md deep; do
  if [ -e "$src/$stray" ]; then
    printf 'ERROR: 원본 트리에 테스트 artifact 가 남았다: %s\n' "$stray" >&2
    exit 2
  fi
done
if ! "$src/scripts/validate_testagent.sh" >/dev/null 2>&1; then
  printf 'ERROR: 원본 트리가 validator 를 통과하지 못한다\n' >&2
  exit 2
fi
printf '원본 트리 무오염 확인: validator PASS\n'

# 정리 확인은 이 실행이 만든 부모 디렉터리 안만 본다 — /tmp 전역 glob 을 쓰면 남의 잔여물이나
# 병렬 실행 때문에 정상 실행이 ERROR 로 떨어진다.
if [ -n "$(ls -A "$work_root" 2>/dev/null)" ]; then
  printf 'ERROR: 케이스 임시 경로가 남았다: %s\n' "$work_root" >&2
  exit 2
fi
printf '임시 경로 정리 확인: 케이스 디렉터리 0건\n'

[ "$fail" -eq 0 ] || exit 1
