#!/bin/bash
set -e

SKILL="skill-builder"
SKILL_SRC="$(cd "$(dirname "$0")/skills/$SKILL" && pwd)"

install_to() {
  local dest="$1/$SKILL"
  mkdir -p "$dest"
  cp -r "$SKILL_SRC/." "$dest/"
  echo "  ✓ $dest"
}

echo "Installing $SKILL skill..."
echo ""

install_to "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"          # Claude Code
install_to "$HOME/.agents/skills"                                # Codex / Amp / Goose / Kiro
install_to "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"   # opencode
install_to "$HOME/.gemini/antigravity/skills"                    # Gemini CLI
install_to "$HOME/.openclaw/workspace/skills"                    # OpenClaw

echo ""
echo "Done. Invoke with: /skill-builder \"what the skill should do\""
echo "Reinstall anytime:  bash install.sh"
