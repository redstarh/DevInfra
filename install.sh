#!/bin/bash
# Claude Code 설정 일괄 설치 스크립트
# 2026-04-13 기준 — SVG agent 위임 전환 버전
#
# 사용법:
#   gh repo clone reddotkim/claude-config ~/.claude
#   cd ~/.claude && ./install.sh
#
# 또는 기존 ~/.claude가 있는 경우:
#   gh repo clone reddotkim/claude-config /tmp/claude-config
#   /tmp/claude-config/install.sh
#
# 포함 항목:
#   - CLAUDE.md (OMC 오케스트레이션 + 개인 규칙)
#   - AGENTS.md (에이전트 카탈로그)
#   - settings.json (hooks 7개, plugins 3개, statusLine)
#   - settings.local.json (permissions, env)
#   - rules/ 15개 (SVG, 4-Lenses, 개발 원칙, 코드 리뷰, TS, Web)
#   - scripts/self-verify-gate.sh (SVG hook)
#   - statusline.sh (모델/컨텍스트/비용 표시)
#   - .mcp.json, .omc-config.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Claude Code 설정 일괄 설치 ==="
echo ""

# ── Step 0: Prerequisites 자동 설치 ──
echo "[0/7] Prerequisites 확인 및 설치..."

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "  ⚠ Homebrew 필요. 설치:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
echo "  ✓ Homebrew"

# Node.js
if ! command -v node &>/dev/null; then
    echo "  설치 중: Node.js..."
    brew install node
fi
echo "  ✓ Node.js $(node --version)"

# jq (hook에서 JSON 파싱에 사용)
if ! command -v jq &>/dev/null; then
    echo "  설치 중: jq..."
    brew install jq
fi
echo "  ✓ jq $(jq --version)"

# GitHub CLI (repo 관리용)
if ! command -v gh &>/dev/null; then
    echo "  설치 중: GitHub CLI..."
    brew install gh
fi
echo "  ✓ gh $(gh --version | head -1)"

# Claude Code
if ! command -v claude &>/dev/null; then
    echo "  설치 중: Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi
echo "  ✓ Claude Code $(claude --version 2>/dev/null | head -1)"

echo ""

# ── Step 1: Backup ──
echo "[1/7] 기존 설정 백업..."
if [ -d "$CLAUDE_DIR" ] && [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    for f in CLAUDE.md AGENTS.md settings.json settings.local.json .mcp.json .omc-config.json statusline.sh; do
        [ -f "$CLAUDE_DIR/$f" ] && cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/" && echo "  백업: $f"
    done
    [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/rules" && echo "  백업: rules/"
    [ -d "$CLAUDE_DIR/scripts" ] && cp -r "$CLAUDE_DIR/scripts" "$BACKUP_DIR/scripts" && echo "  백업: scripts/"
    echo "  → 백업 위치: $BACKUP_DIR"
elif [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo "  새로 생성: $CLAUDE_DIR"
else
    echo "  스킵 (repo에서 직접 실행 중)"
fi
echo ""

# ── Step 2: Core config files ──
echo "[2/7] 코어 설정 파일 복사..."
for f in CLAUDE.md AGENTS.md settings.json settings.local.json .mcp.json .omc-config.json statusline.sh; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        if [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
            cp "$SCRIPT_DIR/$f" "$CLAUDE_DIR/$f"
        fi
        echo "  ✓ $f"
    fi
done
chmod +x "$CLAUDE_DIR/statusline.sh"
echo ""

# ── Step 3: Rules ──
echo "[3/7] Rules 설치..."
mkdir -p "$CLAUDE_DIR/rules/common" "$CLAUDE_DIR/rules/typescript" "$CLAUDE_DIR/rules/web"
if [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
    cp "$SCRIPT_DIR/rules/"*.md "$CLAUDE_DIR/rules/" 2>/dev/null || true
    cp "$SCRIPT_DIR/rules/common/"*.md "$CLAUDE_DIR/rules/common/" 2>/dev/null || true
    cp "$SCRIPT_DIR/rules/typescript/"*.md "$CLAUDE_DIR/rules/typescript/" 2>/dev/null || true
    cp "$SCRIPT_DIR/rules/web/"*.md "$CLAUDE_DIR/rules/web/" 2>/dev/null || true
fi
RULE_COUNT=$(find "$CLAUDE_DIR/rules" -name '*.md' | wc -l | tr -d ' ')
echo "  ✓ ${RULE_COUNT}개 rules 파일"
echo ""

# ── Step 4: Scripts ──
echo "[4/7] Scripts 설치..."
mkdir -p "$CLAUDE_DIR/scripts"
if [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
    cp "$SCRIPT_DIR/scripts/self-verify-gate.sh" "$CLAUDE_DIR/scripts/" 2>/dev/null || true
fi
chmod +x "$CLAUDE_DIR/scripts/self-verify-gate.sh" 2>/dev/null || true
echo "  ✓ self-verify-gate.sh (SVG agent 위임 hook)"
echo ""

# ── Step 5: Plugins ──
echo "[5/7] Plugins 설치..."

install_plugin() {
    local name="$1"
    local display="$2"
    if claude plugin list 2>/dev/null | grep -q "$name"; then
        echo "  ✓ $display (이미 설치됨)"
    else
        echo "  설치 중: $display..."
        CLAUDECODE="" claude plugin install "$name" 2>/dev/null && echo "  ✓ $display" || echo "  ⚠ $display 수동 설치 필요: claude plugin install $name"
    fi
}

install_plugin "oh-my-claudecode" "OMC (oh-my-claudecode)"
install_plugin "typescript-lsp" "TypeScript LSP"
install_plugin "pyright-lsp" "Pyright LSP (Python)"
echo ""

# ── Step 6: Permissions 확인 ──
echo "[6/7] 실행 권한 확인..."
chmod +x "$CLAUDE_DIR/statusline.sh" 2>/dev/null && echo "  ✓ statusline.sh"
chmod +x "$CLAUDE_DIR/scripts/self-verify-gate.sh" 2>/dev/null && echo "  ✓ self-verify-gate.sh"
echo ""

# ── Step 7: Verify ──
echo "[7/7] 설치 검증..."
ERRORS=0

check_file() {
    if [ -f "$1" ]; then
        echo "  ✓ $2"
    else
        echo "  ✗ $2 — 누락!"
        ERRORS=$((ERRORS + 1))
    fi
}

check_cmd() {
    if command -v "$1" &>/dev/null; then
        echo "  ✓ $2"
    else
        echo "  ✗ $2 — 미설치!"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "  [파일]"
check_file "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"
check_file "$CLAUDE_DIR/AGENTS.md" "AGENTS.md"
check_file "$CLAUDE_DIR/settings.json" "settings.json"
check_file "$CLAUDE_DIR/settings.local.json" "settings.local.json"
check_file "$CLAUDE_DIR/statusline.sh" "statusline.sh"
check_file "$CLAUDE_DIR/scripts/self-verify-gate.sh" "scripts/self-verify-gate.sh"
check_file "$CLAUDE_DIR/rules/self-verification-gate.md" "rules/SVG"
check_file "$CLAUDE_DIR/rules/four-lenses-design-review.md" "rules/4-Lenses"
check_file "$CLAUDE_DIR/rules/code-development-principles.md" "rules/개발원칙"

echo "  [도구]"
check_cmd "node" "Node.js"
check_cmd "claude" "Claude Code"
check_cmd "jq" "jq"
check_cmd "gh" "GitHub CLI"

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "=== 설치 완료! ==="
    echo ""
    echo "다음 단계:"
    echo "  1. claude 실행 후 Anthropic 계정 인증"
    echo "  2. 'setup omc' 입력하여 OMC 초기화"
    echo "  3. 프로젝트별 .claude/rules/ 추가 설정 (선택)"
    echo "  4. MCP 서버 필요시 ~/.claude/.mcp.json 에 추가"
    echo ""
    if [ -d "$BACKUP_DIR" ] 2>/dev/null; then
        echo "백업 위치: $BACKUP_DIR"
    fi
else
    echo "=== 설치 불완전 ($ERRORS건 누락) ==="
    echo "위 ✗ 항목을 확인 후 재실행하세요."
    exit 1
fi
