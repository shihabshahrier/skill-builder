# Install Paths Reference

All agent skill discovery paths. Skills placed here are auto-discovered without
any config changes. Based on Agent Skills open standard (December 2025).

---

## Global Paths (user-level, available in all projects)

| Agent | Global install path |
|-------|---------------------|
| Claude Code | `~/.claude/skills/{name}/` |
| OpenAI Codex | `~/.agents/skills/{name}/` |
| opencode (SST) | `~/.config/opencode/skills/{name}/` OR `~/.claude/skills/` OR `~/.agents/skills/` |
| Gemini CLI (Google) | `~/.gemini/antigravity/skills/{name}/` |
| OpenClaw | `~/.openclaw/workspace/skills/{name}/` |
| Amp (Sourcegraph) | `~/.agents/skills/{name}/` |
| Goose (Block) | `~/.agents/skills/{name}/` |
| Kiro (AWS) | `~/.agents/skills/{name}/` |

**Key:** opencode checks `~/.claude/skills/` and `~/.agents/skills/` too — a skill installed
for Claude Code is automatically available in opencode.

---

## Project Paths (repo-level, scoped to project)

| Agent | Project install path |
|-------|----------------------|
| Claude Code | `.claude/skills/{name}/` |
| OpenAI Codex | `.agents/skills/{name}/` |
| opencode | `.opencode/skills/{name}/` OR `.claude/skills/` OR `.agents/skills/` |
| Most others | `.agents/skills/{name}/` |

Project paths take precedence over global paths (same name = project version wins).

---

## Path Resolution Order (opencode)

opencode walks upward from the current directory checking these in order:
1. `.opencode/skills/` (current dir → worktree root)
2. `.claude/skills/` (current dir → worktree root)
3. `.agents/skills/` (current dir → worktree root)
4. `~/.config/opencode/skills/`
5. `~/.claude/skills/`
6. `~/.agents/skills/`

---

## install.sh Template

```bash
#!/bin/bash
set -e

SKILL="{SKILL_NAME}"
SKILL_SRC="$(cd "$(dirname "$0")/skills/$SKILL" && pwd)"

install_to() {
  local dest="$1/$SKILL"
  mkdir -p "$dest"
  cp -r "$SKILL_SRC/." "$dest/"
  echo "  ✓ $dest"
}

echo "Installing $SKILL skill..."

install_to "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"          # Claude Code
install_to "$HOME/.agents/skills"                                # Codex / Amp / Goose / Kiro
install_to "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"   # opencode
install_to "$HOME/.gemini/antigravity/skills"                    # Gemini CLI
install_to "$HOME/.openclaw/workspace/skills"                    # OpenClaw

echo ""
echo "Done. Invoke: /{SKILL_NAME}"
echo "Reinstall: bash install.sh"
```

---

## Manual Install (per agent)

```bash
# Claude Code
mkdir -p ~/.claude/skills/{name}
cp -r skills/{name}/. ~/.claude/skills/{name}/

# Codex
mkdir -p ~/.agents/skills/{name}
cp -r skills/{name}/. ~/.agents/skills/{name}/

# opencode
mkdir -p ~/.config/opencode/skills/{name}
cp -r skills/{name}/. ~/.config/opencode/skills/{name}/

# Gemini CLI
mkdir -p ~/.gemini/antigravity/skills/{name}
cp -r skills/{name}/. ~/.gemini/antigravity/skills/{name}/

# OpenClaw
mkdir -p ~/.openclaw/workspace/skills/{name}
cp -r skills/{name}/. ~/.openclaw/workspace/skills/{name}/
```

---

## Verification (Claude Code)

```bash
# List installed skills
ls ~/.claude/skills/

# Verify SKILL.md is valid
python3 -c "
import yaml, sys
with open('skills/{name}/SKILL.md') as f:
    content = f.read()
fm = content.split('---')[1]
data = yaml.safe_load(fm)
assert 'name' in data, 'missing name'
assert 'description' in data, 'missing description'
assert len(data['description']) <= 1024, 'description too long'
import re
assert re.match(r'^[a-z0-9]+(-[a-z0-9]+)*\$', data['name']), 'invalid name format'
print('SKILL.md valid:', data['name'])
"
```

---

## Agent-Specific Notes

**Claude Code**: Also discovers skills at startup from `$CLAUDE_CONFIG_DIR/skills/`
(defaults to `~/.claude/skills/`). Override with `CLAUDE_CONFIG_DIR` env var.

**Codex**: Also scans parent directories upward from CWD for `.agents/skills/`.
System-level: `/etc/codex/skills/` (admin-managed).

**opencode**: Reads `AGENTS.md` at project root as always-on rules (separate from skills).
Also reads `CLAUDE.md` for Claude Code compatibility.

**Gemini CLI**: `antigravity` is the internal codename for the Gemini CLI skills subsystem.
Path is literal: `~/.gemini/antigravity/skills/`.

**OpenClaw**: Uses `SOUL.md` for agent persona, `AGENTS.md` for rules, `TOOLS.md` for tool
definitions. Skills go at `~/.openclaw/workspace/skills/`.
