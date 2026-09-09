#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name' | sed 's/global\.anthropic\.//;s/us\.anthropic\.//;s/claude-//')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST=${COST:-0}
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
PCT=${PCT:-0}
REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // 0' | cut -d. -f1)
REMAINING=${REMAINING:-0}
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
INPUT_TOKENS=${INPUT_TOKENS:-0}
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
OUTPUT_TOKENS=${OUTPUT_TOKENS:-0}

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

COST_FMT=$(printf '$%.2f' "$COST")

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/} | ${BAR_COLOR}${BAR}${RESET} ${PCT}% (${REMAINING}% left)"
echo -e "In:${INPUT_TOKENS} Out:${OUTPUT_TOKENS} | 💰 ${COST_FMT}"
