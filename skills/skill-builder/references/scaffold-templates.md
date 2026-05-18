# Scaffold Templates Reference

File contents for `--repo` scaffold. Load only during Phase 7 (Scaffold Repo).

---

## Table of Contents

- [Repo structure](#repo-structure)
- [agents/openai.yaml](#agentsopenaiiyaml)
- [install.sh](#installsh)
- [AGENTS.md and GEMINI.md](#agentsmd-and-geminimd)
- [gemini-extension.json](#gemini-extensionjson)
- [.gitignore](#gitignore)
- [Agent rule files](#agent-rule-files)
- [README.md checklist](#readmemd-checklist)
- [CLAUDE.md checklist](#claudemd-checklist)
- [Example: input → output](#example-input--output)

---

## Repo structure

```
{SKILL_NAME}/
  skills/
    {SKILL_NAME}/
      SKILL.md
      references/         ← if NEEDS_REFERENCES
        {domain}.md
  hooks/                  ← if NEEDS_HOOKS
    activate.js
    tracker.js
    package.json
  agents/
    openai.yaml           ← Codex display config
  .claude-plugin/
    plugin.json
    marketplace.json
  .cursor/
    rules/{SKILL_NAME}.mdc
  .windsurf/
    rules/{SKILL_NAME}.md
  .clinerules/
    {SKILL_NAME}.md
  .codex/
    config.toml
    hooks.json
  .github/
    FUNDING.yml
    ISSUE_TEMPLATE/
      bug_report.md
      feature_request.md
    copilot-instructions.md
  .gitattributes
  .gitignore
  AGENTS.md
  CLAUDE.md
  CONTRIBUTING.md
  GEMINI.md
  gemini-extension.json
  install.sh
  LICENSE
  README.md
```

---

## agents/openai.yaml

Codex display + behavior config:

```yaml
interface:
  display_name: "{SKILL_DISPLAY_NAME}"
  short_description: "{SHORT_DESCRIPTION}"
policy:
  allow_implicit_invocation: false
```

Set `allow_implicit_invocation: true` only for reference skills (auto-applicable).

---

## install.sh

Installs to all agent paths:

```bash
#!/bin/bash
set -e
SKILL="{SKILL_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skills/$SKILL"

install_to() {
  local dest="${1}/$SKILL"
  mkdir -p "$dest"
  cp -r "$SKILL_SRC/." "$dest/"
  echo "  ✓ $dest"
}

echo "Installing $SKILL skill..."
install_to "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"          # Claude Code
install_to "$HOME/.agents/skills"                                # Codex, Amp, Goose
install_to "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"   # opencode
install_to "$HOME/.gemini/antigravity/skills"                    # Gemini CLI
install_to "$HOME/.openclaw/workspace/skills"                    # OpenClaw

echo ""
echo "Done. Invoke with: /{SKILL_NAME}"
echo "Reinstall anytime: bash install.sh"
```

---

## AGENTS.md and GEMINI.md

Both use `@` include — Claude Code and opencode expand at load time:

```
@./skills/{SKILL_NAME}/SKILL.md
```

---

## gemini-extension.json

```json
{"name":"{SKILL_NAME}","description":"{SHORT_DESCRIPTION}","version":"1.0.0","contextFileName":"GEMINI.md"}
```

---

## .gitignore

```
__pycache__/
*.pyc
.venv/
.env
.env.local
**/.DS_Store
node_modules/
```

---

## Agent rule files

Cursor, Windsurf, Cline, Copilot — see `references/agent-rules.md` for format templates.
Each file: invocation syntax + phase list (one line each) + critical constraints. Max 30 lines.

---

## README.md checklist

Must include:
- What it does (1-2 sentences + example output tree)
- Install section with `bash install.sh` + per-agent manual paths
- Usage table (args + defaults)
- Requirements (any external tools)
- Feature table
- How it works (phase pipeline)
- Agent support table
- Contributing link

---

## CLAUDE.md checklist

Must include:
- What this repo is
- Source of truth files (edit only `skills/`)
- Agent-specific files (synced, don't edit directly)
- Key constraints
- How to make changes

---

## Example: input → output

**Input**: `/skill-builder "compress images before committing" --type tool --repo`

**Output** (partial):
```yaml
# Generated SKILL.md frontmatter
---
name: image-compressor
description: >
  Compress images before git commits to reduce repo size.
  Invoke: /image-compressor [--quality 80] [--format webp|avif|original]
  Outputs optimized images in-place, reports bytes saved.
license: MIT
user-invocable: true
argument-hint: '[--quality 80] [--format webp|avif|original]'
---
```

**Output** (repo tree):
```
image-compressor/
  skills/image-compressor/SKILL.md
  skills/image-compressor/references/compression-api.md
  install.sh
  README.md
  LICENSE
  CLAUDE.md
  AGENTS.md
  GEMINI.md
  .cursor/rules/image-compressor.mdc
  .windsurf/rules/image-compressor.md
  ...
```
