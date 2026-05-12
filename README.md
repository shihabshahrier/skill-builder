# skill-builder

Build any AI agent skill from a plain-English description. One command, production-ready output.

Works with every agent that supports the [Agent Skills open standard](https://agentskills.io) —
Claude Code, Codex, opencode, Cursor, Windsurf, Gemini CLI, OpenClaw, Cline, Copilot, and 20+ more.

---

## What it does

```
/skill-builder "compress images before committing"
```

→ Generates:

```
image-compressor/
  skills/
    image-compressor/
      SKILL.md              ← complete, correct frontmatter + body
      references/
        compression-api.md  ← domain knowledge, lazily loaded
  install.sh                ← installs to all 5 agent paths
  README.md
  LICENSE
  ...
```

The skill works immediately after running `bash install.sh`. No config changes needed.

---

## Install

### Claude Code

```bash
claude plugin install shihabshahrier/skill-builder
```

### All other agents (opencode, Codex, Gemini CLI, OpenClaw, Cursor, Windsurf, Cline)

```bash
git clone https://github.com/shihabshahrier/skill-builder
cd skill-builder
bash install.sh
```

`install.sh` copies the skill to all 5 agent discovery paths automatically.

### Manual (one agent)

```bash
# Claude Code
mkdir -p ~/.claude/skills/skill-builder
cp -r skills/skill-builder/. ~/.claude/skills/skill-builder/

# Codex
mkdir -p ~/.agents/skills/skill-builder
cp -r skills/skill-builder/. ~/.agents/skills/skill-builder/

# Gemini CLI
mkdir -p ~/.gemini/antigravity/skills/skill-builder
cp -r skills/skill-builder/. ~/.gemini/antigravity/skills/skill-builder/
```

### Verify

```bash
# Claude Code — skill appears in listing
/help

# Any agent — invoke directly
/skill-builder "what does this skill do"
```

---

## Usage

### Build a new skill

```
/skill-builder "description"
/skill-builder "description" --type workflow|mode|tool|reference|agent
/skill-builder "description" --type workflow --repo
```

### Audit an existing skill

```
/skill-builder --audit skills/my-skill/SKILL.md
/skill-builder --audit skills/my-skill/SKILL.md --fix
```

`--audit` runs the full quality checklist against any SKILL.md — checks frontmatter spec compliance, body structure, size budget, reference quality, placeholder substitution, and more. Reports every failure with exact fix instructions.

`--fix` goes further: outputs a corrected SKILL.md with all failures resolved. Sections that pass are left untouched.

### All flags

| Arg | Default | Values |
|-----|---------|--------|
| description | required (unless --audit) | plain English, what the skill does |
| --type | auto-detected | workflow, mode, tool, reference, agent |
| --repo | off | scaffold full marketplace-ready repo |
| --audit | off | path to existing SKILL.md to audit |
| --fix | off | with --audit: also output corrected SKILL.md |

**Without `--repo`**: generates `skills/{name}/SKILL.md` + references only.
**With `--repo`**: generates a complete publish-ready repo with all agent rules, install script, README, LICENSE, CI boilerplate.

---

## Skill types

| Type | When to use | Example |
|------|-------------|---------|
| **workflow** | Multi-step pipeline producing artifacts | `"scaffold a FastAPI project"` |
| **mode** | Persistent behavior change every response | `"always respond formally"` |
| **tool** | One-shot action on a target | `"compress CSS before commit"` |
| **reference** | Domain knowledge that guides behavior | `"know our API conventions"` |
| **agent** | Autonomous multi-role persona | `"act as a full-stack dev firm"` |

---

## Supported agents

| Agent | Discovery path |
|-------|---------------|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex | `~/.agents/skills/` |
| opencode (SST) | `~/.config/opencode/skills/` + `~/.claude/skills/` + `~/.agents/skills/` |
| Gemini CLI | `~/.gemini/antigravity/skills/` |
| OpenClaw | `~/.openclaw/workspace/skills/` |
| Cursor | `.cursor/rules/` (condensed rule file) |
| Windsurf | `.windsurf/rules/` (condensed rule file) |
| Cline | `.clinerules/` (condensed rule file) |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Any AGENTS.md agent | `AGENTS.md` include |

`install.sh` handles the top 5 automatically. The bottom 5 use in-repo rule files (included in `--repo` scaffold).

---

## How it works

### Create path (8 phases)

```
Phase 0:   Route — detect --audit flag; branch to audit path if present
Phase 1:   Classify skill type (auto or from --type flag)
Phase 2:   Gather requirements (≤3 questions total)
Phase 1.5: Domain research — WebSearch official docs for every tool/API
           the skill references; verified facts only, no guessing
Phase 3:   Generate SKILL.md (correct frontmatter + body for type)
Phase 4:   Generate references/ (populated from research, lazily loaded)
Phase 5:   Generate hooks/ (mode skills only — SessionStart + UserPromptSubmit)
Phase 6:   Scaffold full repo (--repo flag only)
Phase 7:   Report + install commands
```

### Audit path (Phase A)

```
Step 1: Read SKILL.md at given path
Step 2: Run full quality checklist (spec, body, references, size budget)
Step 3: Output audit report — [FAIL] / [WARN] / passed count
Step 4: If --fix — output corrected SKILL.md (failures only, passing sections unchanged)
```

### Knows

- All Agent Skills open standard frontmatter: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`
- Full Claude Code / opencode extended fields: `user-invocable`, `disable-model-invocation`, `argument-hint`, `when_to_use`, `model`, `effort`, `context`, `agent`, `paths`, `shell`, `hooks`
- Codex `agents/openai.yaml` format
- All 5 agent discovery paths + `install.sh` template
- Hook patterns for mode skills (safeWriteFlag, silent-fail, per-turn reinforcement)
- All agent rule file formats (Cursor `.mdc`, Windsurf `.md`, Cline, Codex, Copilot)
- Progressive disclosure model: SKILL.md ≤5000 tokens, references on-demand, TOC for large files

---

## Requirements

None. Pure markdown + bash. No build step, no runtime, no package manager.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
Edit only `skills/skill-builder/SKILL.md` and `skills/skill-builder/references/*.md`.
