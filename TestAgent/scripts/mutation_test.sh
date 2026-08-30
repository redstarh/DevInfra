#!/usr/bin/env bash
# validate_testagent.sh 의 검사 강도를 mutation 으로 확인한다.
#
# 원본 트리는 절대 수정하지 않는다 — 매 케이스마다 mktemp -d 사본을 만들어 거기에만 변형을 적용하고
# 즉시 삭제한다. 각 케이스는 "이 변형을 넣으면 validator 가 잡아야 한다"는 단정이며, 기대 종료 코드와
# 실제 종료 코드를 대조한다.
#
# ⚠️ 이 파일은 validate_testagent.sh 의 금지 문구 검사 대상에서 제외된다.
#    금지 문구를 주입 재료로 다루는 것이 이 러너의 목적이므로, 검사 대상에 넣으면 테스트 자산 자체가
#    위반으로 잡힌다. 제외 근거는 validate_testagent.sh 의 reject_text 주석에 함께 적어 둔다.

set -uo pipefail   # -e 는 쓰지 않는다: 실패 케이스의 exit 1 을 직접 읽어야 한다

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass=0
fail=0

# 금지 문구는 변수로 둔다 — 이 러너가 검사 대상에 들어가더라도 의도를 읽기 쉽게 남긴다.
guard_upper_a="AGENTS.md"
guard_upper_c="CLAUDE.md"
guard_lower="callback"

apply_mutation() {
  local t="$1" id="$2"
  case "$id" in
    M0)  : ;;
    M1)  rm "$t/templates/test-report.md" ;;
    M2)  : > "$t/templates/scenario-matrix.md" ;;
    M3)  sed -i '' 's/테스트 실행 표면 정리/뒷정리/g' "$t/TEST_AGENT.md" ;;
    M4)  printf '\n%s 를 읽는다.\n' "$guard_upper_c" >> "$t/README.md" ;;
    M5)  for f in "$t/validation/"*.md; do
           printf '\n%s 에 의존한다.\n' "$guard_upper_a" >> "$f"
           break
         done ;;
    M6)  printf 'x' > "$t/templates/test-report.md" ;;
    M7)  printf '\n%s 으로 완료를 받는다.\n' "$guard_lower" >> "$t/templates/test-plan.md" ;;
    M8)  printf '\n%s 와 %s 를 본다.\n' \
           "$(printf '%s' "$guard_upper_c" | tr 'A-Z' 'a-z')" \
           "$(printf '%s' "$guard_upper_a" | tr 'A-Z' 'a-z')" >> "$t/README.md" ;;
    M9)  printf '\n%s 으로 완료를 받는다.\n' "Callback" >> "$t/TEST_AGENT.md" ;;
    M10) printf '%s 에 의존한다.\n' "$guard_upper_a" > "$t/adapter-notes.txt" ;;
    M11) printf '\n' > "$t/templates/test-plan.md" ;;
    M12) sed -i '' '/^[^#]/d' "$t/scripts/forbidden-tokens.txt" ;;
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
  esac
}

run_case() {
  local id="$1" want="$2" desc got=0 w
  desc="$(describe "$id")"
  w="$(mktemp -d "/tmp/testagent-mutation-${id}-XXXXXX")" || {
    printf 'ERROR: mktemp 실패\n' >&2
    exit 2
  }
  cp -R "$src" "$w/TestAgent"
  apply_mutation "$w/TestAgent" "$id"
  "$w/TestAgent/scripts/validate_testagent.sh" >/dev/null 2>&1 || got=$?
  rm -rf "$w"

  if [ "$got" -eq "$want" ]; then
    printf 'PASS  %-4s exit=%d          %s\n' "$id" "$got" "$desc"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-4s exit=%d (기대 %d)  %s\n' "$id" "$got" "$want" "$desc"
    fail=$((fail + 1))
  fi
}

printf '=== mutation test: validate_testagent.sh ===\n'

run_case M0  0    # 무변형은 통과해야 한다
run_case M1  1
run_case M2  1
run_case M3  1
run_case M4  1
run_case M5  1
run_case M6  1
run_case M7  1
run_case M8  1
run_case M9  1
run_case M10 1
run_case M11 1
run_case M12 1

printf -- '--- %d passed, %d failed ---\n' "$pass" "$fail"

# 원본 트리가 오염되지 않았는지 확인한다.
if [ -e "$src/adapter-notes.txt" ]; then
  printf 'ERROR: 원본 트리에 테스트 artifact 가 남았다: adapter-notes.txt\n' >&2
  exit 2
fi
if ! "$src/scripts/validate_testagent.sh" >/dev/null 2>&1; then
  printf 'ERROR: 원본 트리가 validator 를 통과하지 못한다\n' >&2
  exit 2
fi
printf '원본 트리 무오염 확인: validator PASS\n'

# 임시 경로 잔존 확인 (§7 정리 검증)
if compgen -G "/tmp/testagent-mutation-*" > /dev/null; then
  printf 'ERROR: 임시 경로가 남았다\n' >&2
  exit 2
fi
printf '임시 경로 정리 확인: 잔존 없음\n'

[ "$fail" -eq 0 ] || exit 1
