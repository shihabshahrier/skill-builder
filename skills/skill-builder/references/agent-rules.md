# Agent Rules Reference

How to write condensed skill rules for each agent type. Used when generating
agent-specific rule files during `--repo` scaffold. Load only during Phase 5.

---

## Condensation Rules

Agent rule files are NOT copies of SKILL.md. Compressed summaries ≤30 lines.

Strip: prose explanations, phase detail, reference load instructions, token efficiency
section, open-weight rules, "why" justifications.

Keep: invocation syntax (exact), phase list (one line per phase), critical constraints,
library/API-specific correction tables.

---

## Cursor (`.cursor/rules/{skill-name}.mdc`)

```markdown
---
description: "{skill-name} — {what it does} when user invokes /{skill-name}"
alwaysApply: {true if mode skill, false for all others}
---

When user says `/{skill-name}`, follow `skills/{skill-name}/SKILL.md`.

**Invocation**: `/{skill-name} {args}`

**Phases**:
1. {Phase 0}: {one line}
2. {Phase N}: {one line}

**Critical**:
- {constraint 1}
- {constraint 2}
```

`alwaysApply: true` — mode skills only. `alwaysApply: false` — all other types.

---

## Windsurf (`.windsurf/rules/{skill-name}.md`)

```markdown
---
trigger: {always_on if mode, manual otherwise}
---

When user says `/{skill-name}`, follow `skills/{skill-name}/SKILL.md`.

**Invocation**: `/{skill-name} {args}`
**Phases**: {phase 1} → {phase 2} → ... → report
**Critical**: {constraint 1}; {constraint 2}
```

`trigger: always_on` — mode skills only. `trigger: manual` — all other types.

---

## Cline (`.clinerules/{skill-name}.md`)

No frontmatter. Cline auto-injects all `.clinerules/*.md` files as context.

```markdown
When user says `/{skill-name}`, follow `skills/{skill-name}/SKILL.md`.

**Invocation**: `/{skill-name} {args}`
**Phases**: {comma-separated one-liners}
**Rules**: {constraint 1}; {constraint 2}
```

---

## Copilot (`.github/copilot-instructions.md`)

No frontmatter. Applied repo-wide as always-on context.

```markdown
When user says `/{skill-name}`, follow `skills/{skill-name}/SKILL.md`.

**Invocation**: `/{skill-name} {args}`
**{N} phases**: {comma-separated names}
**{library} only** — `{correct import}`. Never `{wrong alternative}`.
```

---

## Codex (`.codex/hooks.json` + `agents/openai.yaml`)

`.codex/config.toml`:
```toml
[features]
codex_hooks = true
```

`.codex/hooks.json` — prints skill availability on session start:
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup|resume",
      "hooks": [{
        "type": "command",
        "command": "echo '{skill-name} skill available. /{skill-name} {args}. Phases: {list}. See skills/{skill-name}/SKILL.md.'",
        "timeout": 5,
        "statusMessage": "Loading {skill-name}..."
      }]
    }]
  }
}
```

`agents/openai.yaml` — Codex display + invocation policy:
```yaml
interface:
  display_name: "{Skill Display Name}"
  short_description: "{one sentence}"
policy:
  allow_implicit_invocation: false   # true for reference skills only
```

---

## AGENTS.md / GEMINI.md

Both use `@` include — Claude Code and opencode expand at load time:
```
@./skills/{skill-name}/SKILL.md
```

---

## gemini-extension.json

Tells Gemini CLI to load GEMINI.md as context file:
```json
{
  "name": "{skill-name}",
  "description": "{description}",
  "version": "1.0.0",
  "contextFileName": "GEMINI.md"
}
```

Without this file, Gemini CLI won't auto-load GEMINI.md.

---

## Mode Skill Hooks (Claude Code + opencode)

### `hooks/package.json`
```json
{"type": "commonjs"}
```
Required: pins directory as CommonJS. Without it, `require()` breaks if any ancestor
`package.json` uses `"type": "module"`.

### `hooks/activate.js` (SessionStart)
```javascript
const fs = require('fs');
const path = require('path');
const os = require('os');

const configDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const flagPath = path.join(configDir, '.{skill-name}-active');

function safeWriteFlag(p, content) {
  try {
    const tmp = p + '.tmp.' + process.pid;
    fs.writeFileSync(tmp, content, { mode: 0o600, flag: 'wx' });
    fs.renameSync(tmp, p);
  } catch {}
}

// Write activation flag
safeWriteFlag(flagPath, 'active');

// Emit skill rules as system context (Claude Code injects stdout)
try {
  const skill = fs.readFileSync(
    path.join(__dirname, '..', 'skills', '{skill-name}', 'SKILL.md'), 'utf8'
  );
  process.stdout.write(skill);
} catch {}
```

### `hooks/tracker.js` (UserPromptSubmit)
```javascript
const fs = require('fs');
const path = require('path');
const os = require('os');

const configDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const flagPath = path.join(configDir, '.{skill-name}-active');

let input = '';
process.stdin.on('data', d => input += d);
process.stdin.on('end', () => {
  try {
    const { prompt = '' } = JSON.parse(input);

    const isOff = /stop {skill-name}|{skill-name} off|disable {skill-name}/i.test(prompt);
    const isOn  = prompt.trim().startsWith('/{skill-name}');

    if (isOff) { try { fs.unlinkSync(flagPath); } catch {} }
    else if (isOn) {
      try {
        const tmp = flagPath + '.tmp.' + process.pid;
        fs.writeFileSync(tmp, 'active', { mode: 0o600, flag: 'wx' });
        fs.renameSync(tmp, flagPath);
      } catch {}
    }

    // Per-turn reminder when active
    let active = false;
    try { fs.accessSync(flagPath); active = true; } catch {}
    if (active && !isOff) {
      process.stdout.write(JSON.stringify({
        hookSpecificOutput: '<!-- {SKILL-NAME} ACTIVE -->'
      }));
    }
  } catch {}
});
```

### `plugin.json` with hooks
```json
{
  "name": "{skill-name}",
  "description": "{description}",
  "author": {"name": "{author}", "url": "{url}"},
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command",
      "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/activate.js\"",
      "timeout": 5, "statusMessage": "Loading {skill-name}..."}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command",
      "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/tracker.js\"",
      "timeout": 5}]}]
  }
}
```

### `plugin.json` without hooks (workflow / tool / reference / agent)
```json
{
  "name": "{skill-name}",
  "description": "{description}",
  "author": {"name": "{author}", "url": "{url}"}
}
```

---

## marketplace.json

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "{skill-name}",
  "description": "{description}",
  "owner": {"name": "{author}", "url": "{url}"},
  "plugins": [{
    "name": "{skill-name}",
    "description": "{punchy one sentence}",
    "source": "./",
    "category": "{education|productivity|developer-tools|writing|other}"
  }]
}
```

Categories: `education` · `productivity` · `developer-tools` · `writing` · `other`

---

## CLAUDE.md Template

```markdown
# CLAUDE.md — {skill-name}

## What this repo is
{skill-name} is a {skill-type} skill for AI coding agents. {one sentence on purpose}.

## Source of truth — edit only these
| File | Controls |
|------|----------|
| `skills/{skill-name}/SKILL.md` | All skill behavior |
| `skills/{skill-name}/references/*.md` | Domain knowledge |
{if hooks}| `hooks/activate.js` | SessionStart behavior |
| `hooks/tracker.js` | Per-turn behavior |{end}

## Agent-specific files (sync from source, don't edit directly)
`.cursor/` · `.windsurf/` · `.clinerules/` · `.codex/` · `.github/copilot-instructions.md`
`AGENTS.md` · `GEMINI.md`

## Key constraints
- {constraint 1}
- {constraint 2}

## Making changes
Edit `skills/{skill-name}/SKILL.md`. Open PR with before/after example.
```
