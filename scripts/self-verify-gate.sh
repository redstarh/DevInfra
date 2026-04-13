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

# 프롬프트 추출 (keyword-detector.mjs와 동일한 JSON 구조 지원)
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
read -r -d '' CHECKLIST << 'GATE' || true
<svg>
분석/조사 결론 → critic(opus) 위임 후 답변. 설계/방안 → critic(opus) 위임 후 답변.
코드 완료 → code-reviewer(opus). 실행/확인/설정/잡담 → 바로 답변.
자기검증 테이블 금지. 기준: rules/self-verification-gate.md
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
