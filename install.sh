#!/bin/bash
# Claude Code 설정 일괄 설치 스크립트
# 2026-04-13 기준 — ECC 잔재 제거, OMC 전용
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
#   - AGENTS.md (OMC 에이전트 라우팅)
#   - settings.json (hooks 6개, plugins 2개, statusLine)
#   - settings.local.json (permissions, env)
#   - rules/ 4개 (SVG, 4-Lenses, 개발 원칙, 코드 리뷰)
#   - scripts/self-verify-gate.sh (SVG hook)
#   - statusline.sh (모델/컨텍스트/비용 표시)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Claude Code 설정 일괄 설치 ==="
echo ""

# ── Step 0: Prerequisites ──
echo "[0/6] Prerequisites 확인..."

check_or_install() {
    local cmd="$1" name="$2" install_cmd="$3"
    if command -v "$cmd" &>/dev/null; then
        echo "  ✓ $name"
    else
        echo "  설치 중: $name..."
        eval "$install_cmd"
        echo "  ✓ $name"
    fi
}

if ! command -v brew &>/dev/null; then
    echo "  ⚠ Homebrew 필요:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
echo "  ✓ Homebrew"

check_or_install "node" "Node.js" "brew install node"
check_or_install "jq" "jq" "brew install jq"
check_or_install "gh" "GitHub CLI" "brew install gh"
check_or_install "claude" "Claude Code" "npm install -g @anthropic-ai/claude-code"
echo ""

# ── Step 1: Backup ──
echo "[1/6] 기존 설정 백업..."
if [ -d "$CLAUDE_DIR" ] && [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    for f in CLAUDE.md AGENTS.md settings.json settings.local.json statusline.sh; do
        [ -f "$CLAUDE_DIR/$f" ] && cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/" && echo "  백업: $f"
    done
    [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/rules" && echo "  백업: rules/"
    [ -d "$CLAUDE_DIR/scripts" ] && cp -r "$CLAUDE_DIR/scripts" "$BACKUP_DIR/scripts" && echo "  백업: scripts/"
    echo "  → $BACKUP_DIR"
elif [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo "  새로 생성: $CLAUDE_DIR"
else
    echo "  스킵 (repo에서 직접 실행 중)"
fi
echo ""

# ── Step 2: Config 복사 ──
echo "[2/6] 설정 파일 복사..."
for f in CLAUDE.md AGENTS.md settings.json settings.local.json statusline.sh; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ] && cp "$SCRIPT_DIR/$f" "$CLAUDE_DIR/$f"
        echo "  ✓ $f"
    fi
done
chmod +x "$CLAUDE_DIR/statusline.sh"
echo ""

# ── Step 3: Rules + Scripts ──
echo "[3/6] Rules & Scripts 설치..."
mkdir -p "$CLAUDE_DIR/rules/common" "$CLAUDE_DIR/scripts"
if [ "$SCRIPT_DIR" != "$CLAUDE_DIR" ]; then
    cp "$SCRIPT_DIR/rules/"*.md "$CLAUDE_DIR/rules/" 2>/dev/null || true
    cp "$SCRIPT_DIR/rules/common/"*.md "$CLAUDE_DIR/rules/common/" 2>/dev/null || true
    cp "$SCRIPT_DIR/scripts/self-verify-gate.sh" "$CLAUDE_DIR/scripts/" 2>/dev/null || true
fi
chmod +x "$CLAUDE_DIR/scripts/self-verify-gate.sh" 2>/dev/null || true
RULE_COUNT=$(find "$CLAUDE_DIR/rules" -name '*.md' | wc -l | tr -d ' ')
echo "  ✓ rules ${RULE_COUNT}개, scripts/self-verify-gate.sh"
echo ""

# ── Step 4: Plugins ──
echo "[4/6] Plugins 설치..."

install_plugin() {
    local name="$1" display="$2"
    if claude plugin list 2>/dev/null | grep -q "$name"; then
        echo "  ✓ $display (이미 설치됨)"
    else
        echo "  설치 중: $display..."
        CLAUDECODE="" claude plugin install "$name" 2>/dev/null \
            && echo "  ✓ $display" \
            || echo "  ⚠ $display 수동 설치 필요: claude plugin install $name"
    fi
}

# 필수
install_plugin "oh-my-claudecode" "OMC (oh-my-claudecode)"
install_plugin "pyright-lsp" "Pyright LSP (Python)"
echo ""

# ── Step 5: 실행 권한 ──
echo "[5/6] 실행 권한 확인..."
chmod +x "$CLAUDE_DIR/statusline.sh" 2>/dev/null && echo "  ✓ statusline.sh"
chmod +x "$CLAUDE_DIR/scripts/self-verify-gate.sh" 2>/dev/null && echo "  ✓ self-verify-gate.sh"
echo ""

# ── Step 6: 검증 ──
echo "[6/6] 설치 검증..."
ERRORS=0

check_file() {
    [ -f "$1" ] && echo "  ✓ $2" || { echo "  ✗ $2 — 누락!"; ERRORS=$((ERRORS + 1)); }
}
check_cmd() {
    command -v "$1" &>/dev/null && echo "  ✓ $2" || { echo "  ✗ $2 — 미설치!"; ERRORS=$((ERRORS + 1)); }
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
check_file "$CLAUDE_DIR/rules/common/code-review.md" "rules/코드리뷰"

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
    echo "  1. claude 실행 후 인증"
    echo "  2. 'setup omc' 입력하여 OMC 초기화"
    echo "  3. 프로젝트별 .claude/rules/ 추가 (선택)"
else
    echo "=== 설치 불완전 ($ERRORS건 누락) ==="
    echo "위 ✗ 항목 확인 후 재실행하세요."
    exit 1
fi
