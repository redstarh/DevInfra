#!/bin/bash
# Self-Verification Gate — 답변 전 자기 검증 체크리스트 강제 주입
# UserPromptSubmit hook에서 호출
#
# 원칙: "빠른 답변보다 정확한 답변"
# 근거: 2026-04-08 분석 3회 변경 + 설계서 3회 변경 사고
#
# 동작:
#   1. stdin에서 사용자 프롬프트 추출
#   2. 4개 단계(분석/설계/개발/테스트) 체크리스트 항상 전부 주입
#   3. Claude가 해당 단계 선택하여 적용, 나머지 N/A 표시
#
# 키워드 감지 없음 — 감지 실패 원천 차단

set -euo pipefail

INPUT=$(cat)

# 프롬프트 추출 (UserPromptSubmit hook의 JSON 구조 변형 모두 지원)
PROMPT=$(echo "$INPUT" | jq -r '
  if .prompt then .prompt
  elif .message.content then .message.content
  elif .parts then [.parts[] | select(.type == "text") | .text] | join(" ")
  else ""
  end
' 2>/dev/null || echo "")

# 프롬프트가 비어있으면 스킵
if [[ -z "$PROMPT" ]]; then
    jq -n '{continue:true,suppressOutput:true}'
    exit 0
fi

# 컴팩트 리마인더만 주입 (전체 규칙은 rules/self-verification-gate.md에서 세션 시작 시 1회 로드)
# 2026-04-09: 기존 ~650토큰/프롬프트 → ~30토큰/프롬프트로 최적화
# 2026-08-28: 5줄 → 3줄. 지운 것 — "모든 분석·설계 결론에 critic"(과한 트리거. 위임 범위는
#   rules/self-verification-gate.md가 "되돌리기 어려운 결론"으로 좁혀 소유한다) · 기준 파일
#   포인터(CLAUDE.md가 세션 시작에 이미 로드한다). 남긴 3줄은 실제 실패 모드를 막는다.
read -r -d '' CHECKLIST << 'GATE' || true
<svg>
턴마다 반드시 1문장 이상 텍스트 출력 — tool만 쓰고 end_turn 금지.
검증 명령은 메인이 직접 실행해 증거 확보, 판정만 agent 위임 — 검증 테이블 수기 작성 금지.
실행/확인/설정/잡담/진행안내는 skill 강제 없이 바로 답변.
</svg>
GATE

# JSON 출력 (additionalContext로 주입)
jq -n --arg ctx "$CHECKLIST" '{
    continue: true,
    hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext: $ctx
    }
}'

exit 0
