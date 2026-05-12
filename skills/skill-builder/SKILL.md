---
name: skill-builder
description: >
  Build any AI agent skill from a plain-English description. Generates SKILL.md,
  references, hooks, and full marketplace repo scaffold. Supports all 32+ agents
  in the Agent Skills open standard: Claude Code, Codex, opencode, Cursor,
  Windsurf, Gemini CLI, OpenClaw, Cline, Copilot, and more.
  Invoke: /skill-builder "what the skill should do" [--type workflow|mode|tool|reference|agent] [--repo]
  Audit existing skill: /skill-builder --audit path/to/SKILL.md [--fix]
user-invocable: true
argument-hint: '"description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]'
when_to_use: >
  Use when user says build a skill, create a skill, make a skill, generate a skill,
  audit a skill, review a skill, fix a skill, improve a skill, /skill-builder.
---

# Skill Builder

Turn a plain-English description into a production-ready skill compatible with every
agent that implements the Agent Skills open standard (32+ tools, December 2025).

---

## Invocation

```
/skill-builder "compress images before committing"
/skill-builder "remind the model to always write tests first" --type reference
/skill-builder "scaffold a FastAPI project" --type workflow --repo
/skill-builder "make the model speak formally" --type mode --repo
/skill-builder --audit skills/my-skill/SKILL.md
/skill-builder --audit skills/my-skill/SKILL.md --fix
```

| Arg | Default | Values |
|-----|---------|--------|
| description | required (unless --audit) | plain English, what the skill does |
| --type | auto-detect | workflow, mode, tool, reference, agent |
| --repo | off | also scaffold a full marketplace-ready repo |
| --audit | off | path to existing SKILL.md — audit instead of create |
| --fix | off | with --audit: also output corrected SKILL.md |

---

## Phase 0 — Route

**If `--audit` flag present:** skip to [Phase A — Audit](#phase-a--audit).

**Otherwise:** continue to classify.

Load `references/skill-types.md`.

Determine skill type from description:

| Signal | Type |
|--------|------|
| "every time", "always", "mode", "persistently" | **mode** |
| "create", "scaffold", "build", "pipeline", "generate" | **workflow** |
| "compress", "format", "convert", "run X on Y", "transform" | **tool** |
| "remind", "context for", "know about", "rules for" | **reference** |
| "act as", "autonomous", "manage the whole", "firm", "company" | **agent** |

If `--type` provided, skip detection. If ambiguous, ask ONE question:

> "Is this (a) a persistent mode that changes every response, (b) a one-shot action on a specific target, or (c) a multi-step workflow producing artifacts?"

Wait for answer. Never ask more than one question total. Decide the rest.

---

## Phase 1 — Gather Requirements

Load `references/skill-anatomy.md`.

Ask at most 2 more questions total (across Phase 0 + Phase 1). If the description already answers these, skip them entirely:

```
1. Trigger: does the user type /skill-name to invoke, or should it activate automatically?
2. Output: what does it produce — files on disk, changed model behavior, a report, or nothing?
```

Derive:
- `SKILL_NAME` — kebab-case, lowercase alphanumeric + hyphens, 1–64 chars, matches `^[a-z0-9]+(-[a-z0-9]+)*$`
- `TRIGGER` — user-invocable (typed) or auto (always-on, requires SessionStart hook)
- `OUTPUTS` — files / behavior change / report / none
- `NEEDS_HOOKS` — true if mode or auto-trigger
- `NEEDS_REFERENCES` — true if skill needs domain knowledge loaded lazily
- `NEEDS_SCRIPTS` — true if skill runs bash/python tools
- `NEEDS_OPENAI_YAML` — true if Codex-specific display config needed

---

## Phase 1.5 — Domain Research (if NEEDS_REFERENCES)

Before writing any reference files, research the domain to get verified facts.
Skip this phase only if `NEEDS_REFERENCES` is false.

**Step 1 — Identify research targets**

From the skill description, extract:
- Tool/library names (e.g. `imagemagick`, `sharp`, `ffmpeg`, `eslint`)
- APIs or services (e.g. GitHub Actions, Stripe, OpenAI)
- Language/framework specifics (e.g. Rust borrow checker rules, React hooks constraints)
- Any flags, method signatures, or config schemas the skill will reference

**Step 2 — WebSearch for official docs**

For each research target, run a targeted search:
```
WebSearch: "{tool-name} official documentation CLI flags"
WebSearch: "{api-name} API reference {relevant-endpoint}"
WebSearch: "{framework} best practices {specific-topic}"
```

Prioritize:
1. Official docs (docs.tool.io, man pages, GitHub README of the project itself)
2. Spec documents (RFCs, WHATWG, OpenAPI schemas)
3. Recent release notes for version-specific behavior

**Step 3 — Extract and verify**

From search results, extract only:
- Exact flag names and their accepted values
- Method/function signatures with correct parameter names
- Error codes and their meaning
- Version compatibility constraints

**Never include:**
- Anything not confirmed in official sources
- Stack Overflow answers without cross-referencing docs
- Behavior that might have changed since a major version bump

**Step 4 — Build reference stubs**

For each domain area, create a reference stub:
```
references/{domain-slug}.md
  - verified flags / methods / config keys
  - error→fix table for common failures
  - input/output example pairs
  - TOC at top if >100 lines
```

These stubs feed directly into Phase 3.

---

## Phase 2 — Generate SKILL.md

Load `references/skill-anatomy.md` (already loaded).

### Universal Frontmatter

```yaml
---
name: {SKILL_NAME}
description: >
  {Line 1: what it does — verb + object, ≤80 chars}
  {Line 2: how invoked}
  {Line 3: key output or behavior}
  {Line 4: compatibility note if relevant}
license: MIT
---
```

**Claude Code / opencode only — add after `license`:**
```yaml
user-invocable: true                    # user types /skill-name
disable-model-invocation: true          # auto-only, no explicit invoke
argument-hint: '"{description}" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path]'
when_to_use: >
  Use when user says build a skill, create a skill, make a skill, audit a skill.
# Optional — add only when relevant:
model: sonnet                           # override model for this skill
effort: high                            # low|medium|high|xhigh|max
context: fork                           # run in isolated subagent
```

`argument-hint` improves autocomplete UX. `when_to_use` extends trigger matching beyond `description`.
These fields are ignored by Codex, Cursor, Gemini CLI etc. — safe to include, they skip unknown fields.

### Body structure by skill type

Load `references/skill-types.md` for full patterns. Quick summary:

**workflow**: Invocation table → Phase 0 (parse+scaffold) → Phase 1…N (work) → Phase N+1 (report) → Token Efficiency Rules → Open-Weight Model Rules

**mode**: Activation → Persistence → Rules → Intensity Levels → Auto-Clarity → Boundaries

**tool**: Trigger → Process (numbered steps) → Output → Error Handling

**reference**: Purpose → When to Apply → {Domain Sections} → Never Do

**agent**: Prime Directive → Mode Detection table → Phase 0…N → Prohibited Actions → Success Criteria

### Quality rules
- First sentence: action-oriented ("Produce X", "Transform Y"), not "This skill..."
- Every section actionable — no vague guidance
- Code templates for any code the skill generates
- Error tables for any external tool calls
- Reference load instructions appear at the phase that needs them (lazy, not upfront)
- All `{TEMPLATE_VARIABLES}` substituted before outputting — never leave placeholders

---

## Phase 3 — Generate References (if NEEDS_REFERENCES)

For each domain knowledge area:

1. Identify what facts/rules can't live in SKILL.md without bloating it
2. Name: `references/{domain-slug}.md`
3. Structure: headings → tables → code blocks, minimal prose
4. Error→fix tables for any external tool reference
5. Add load instruction in SKILL.md at the phase that needs it: `Load references/{name}.md before {action}.`

Reference rules:
- Verified facts only — never guess API names, flags, or method signatures
- Tables over prose
- Dense, not padded

---

## Phase 4 — Generate Hooks (if NEEDS_HOOKS)

Load `references/agent-rules.md` for full hook templates.

Mode skills only. Two JS files in `hooks/` + `package.json`:

**`hooks/package.json`** — pins CommonJS (required):
```json
{"type": "commonjs"}
```

**`hooks/activate.js`** (SessionStart) — three responsibilities:
1. Write mode flag to `$CLAUDE_CONFIG_DIR/.{skill-name}-active` via safeWriteFlag
2. Emit SKILL.md content to stdout (Claude Code injects as system context)
3. Nudge user about statusline if not configured

**`hooks/tracker.js`** (UserPromptSubmit) — three responsibilities:
1. Parse prompt from stdin JSON
2. Deactivate: if prompt matches "stop {skill}" or "/{skill} off" → delete flag
3. Activate: if prompt matches "/{skill}" → write flag; emit `hookSpecificOutput` reminder

**safeWriteFlag pattern** — atomic, 0600 perms, symlink-safe, silent-fail:
```javascript
function safeWriteFlag(flagPath, content) {
  try {
    const tmp = flagPath + '.tmp.' + process.pid;
    require('fs').writeFileSync(tmp, content, { mode: 0o600, flag: 'wx' });
    require('fs').renameSync(tmp, flagPath);
  } catch {}
}
```

Critical: ALL hook filesystem ops must silent-fail. Hook crash = blocked Claude Code session.

Hook `plugin.json`:
```json
{
  "name": "{SKILL_NAME}",
  "description": "{description}",
  "author": {"name": "{author}", "url": "{url}"},
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command",
      "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/activate.js\"",
      "timeout": 5, "statusMessage": "Loading {SKILL_NAME}..."}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command",
      "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/tracker.js\"",
      "timeout": 5}]}]
  }
}
```

---

## Phase 5 — Scaffold Repo (if --repo)

Load `references/agent-rules.md` and `references/install-paths.md`.

Create full repo structure in a new directory `{SKILL_NAME}/`:

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

### Required file contents

**`agents/openai.yaml`** — Codex display + behavior config:
```yaml
interface:
  display_name: "{Skill Display Name}"
  short_description: "{one punchy sentence}"
policy:
  allow_implicit_invocation: false
```
Set `allow_implicit_invocation: true` only for reference skills (auto-applicable).

**`install.sh`** — installs to all agent paths:
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

**`AGENTS.md`** and **`GEMINI.md`**: `@./skills/{SKILL_NAME}/SKILL.md`

**`gemini-extension.json`**:
```json
{"name":"{SKILL_NAME}","description":"{desc}","version":"1.0.0","contextFileName":"GEMINI.md"}
```

**`.gitignore`**:
```
__pycache__/
*.pyc
.venv/
.env
.env.local
**/.DS_Store
node_modules/
```

**Agent rule files** (Cursor, Windsurf, Cline, Copilot) — see `references/agent-rules.md`.
Each file: invocation syntax + phase list (one line each) + critical constraints. Max 30 lines.

**`README.md`** — must include:
- What it does (1-2 sentences + example output tree)
- Install section with `bash install.sh` + per-agent manual paths
- Usage table (args + defaults)
- Requirements (any external tools)
- Feature table
- How it works (phase pipeline)
- Agent support table
- Contributing link

**`CLAUDE.md`** — contributor guide:
- What this repo is
- Source of truth files (edit only `skills/`)
- Agent-specific files (synced, don't edit directly)
- Key constraints
- How to make changes

---

## Phase 6 — Report

```markdown
## Skill Built: {SKILL_NAME}

**Type**: {skill-type}
**Hooks**: {yes — SessionStart + UserPromptSubmit | no}
**References**: {list filenames or "none"}
**Repo scaffold**: {yes — {SKILL_NAME}/ | no}

### Files created
{list every file path}

### Install now
```bash
# Claude Code & opencode
mkdir -p ~/.claude/skills/{SKILL_NAME} && cp -r skills/{SKILL_NAME}/. ~/.claude/skills/{SKILL_NAME}/

# Codex
mkdir -p ~/.agents/skills/{SKILL_NAME} && cp -r skills/{SKILL_NAME}/. ~/.agents/skills/{SKILL_NAME}/

# All agents at once (from repo root)
bash install.sh
```

### Test
```
/{SKILL_NAME} {example invocation}
```
```

---

## Phase A — Audit (only when --audit flag present)

Load `references/skill-anatomy.md`.

**Step 1 — Read the target skill**

Read the SKILL.md at the path provided with `--audit`. If path doesn't exist, stop and tell the user.

**Step 2 — Extract metadata**

Parse frontmatter. Capture:
- `name`, `description`, `license`, `type` (infer from body if not in frontmatter)
- All present fields vs. expected fields for this skill type
- `SKILL_SIZE` — estimate token count of full file

**Step 3 — Run quality checklist**

Check every item in `references/skill-anatomy.md` Quality Checklist. For each failure, record:
```
[FAIL] {checklist-item}
  Found:    {what's actually there}
  Expected: {what should be there}
  Fix:      {exact change needed}
```

Also run these structural checks:
- Does body structure match required sections for detected skill type?
- Are all `{VARIABLE}` placeholders substituted?
- Are reference files one-level-deep only?
- Does SKILL.md stay under 5000 tokens?
- Do reference files >100 lines have a TOC?
- Are domain facts in references from verified sources or potentially guessed?

**Step 4 — Produce audit report**

```markdown
## Audit: {skill-name}

**Type detected**: {type}
**Size**: ~{N} tokens ({ok | OVER BUDGET — move content to references/})
**Issues found**: {N}

### Failures
{list of [FAIL] entries}

### Warnings
{list of non-blocking issues worth fixing}

### Passed
{count} checks passed.
```

**Step 5 — If --fix flag present**

Output corrected SKILL.md with all failures resolved. Show a diff summary of what changed.
Do not rewrite sections that passed — only fix what failed.
If domain research is needed to fix reference content, run Phase 1.5 first.

---

## Token Efficiency Rules

- Ask 3 questions max total (Phase 0 + Phase 1 combined)
- Load `skill-types.md` once at Phase 0, keep active
- Load `agent-rules.md` only if NEEDS_HOOKS or `--repo` flag
- Load `install-paths.md` only during Phase 5
- Run Phase 1.5 domain research only if NEEDS_REFERENCES is true
- Generate all files in one pass — no file-by-file back-and-forth
- Decide ambiguous choices; note them in report

---

## Open-Weight Model Rules

- Substitute ALL `{TEMPLATE_VARIABLES}` — never output raw placeholders
- Every generated SKILL.md self-contained — no dangling `@` includes in skill body
- JSON files: valid JSON, no comments, no trailing commas
- YAML: valid YAML, correct indentation, quote strings with special chars
- Hook JS: use safeWriteFlag pattern verbatim — don't improvise filesystem writes
- `name` field must match `^[a-z0-9]+(-[a-z0-9]+)*$` — validate before writing
- `description` must be ≤1024 chars — count before writing
