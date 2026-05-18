# Hook Templates Reference

Templates for generating mode skill hooks. Load only during Phase 6 (Generate Hooks).

---

## Table of Contents

- [hooks/package.json](#hookspackagejson)
- [hooks/activate.js (SessionStart)](#hooksactivatejs-sessionstart)
- [hooks/tracker.js (UserPromptSubmit)](#hookstrackerjs-userpromptsubmit)
- [safeWriteFlag pattern](#safewriteflag-pattern)
- [plugin.json with hooks](#pluginjson-with-hooks)
- [plugin.json without hooks](#pluginjson-without-hooks)

---

## hooks/package.json

Pins directory as CommonJS. Without it, `require()` breaks if any ancestor
`package.json` uses `"type": "module"`.

```json
{"type": "commonjs"}
```

---

## hooks/activate.js (SessionStart)

Three responsibilities:
1. Write mode flag to `$CLAUDE_CONFIG_DIR/.{SKILL_NAME}-active` via safeWriteFlag
2. Emit SKILL.md content to stdout (Claude Code injects as system context)
3. Nudge user about statusline if not configured

```javascript
const fs = require('fs');
const path = require('path');
const os = require('os');

const configDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const flagPath = path.join(configDir, '.{SKILL_NAME}-active');

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
    path.join(__dirname, '..', 'skills', '{SKILL_NAME}', 'SKILL.md'), 'utf8'
  );
  process.stdout.write(skill);
} catch {}
```

---

## hooks/tracker.js (UserPromptSubmit)

Three responsibilities:
1. Parse prompt from stdin JSON
2. Deactivate: if prompt matches "stop {SKILL_NAME}" or "/{SKILL_NAME} off" → delete flag
3. Activate: if prompt matches "/{SKILL_NAME}" → write flag; emit `hookSpecificOutput` reminder

```javascript
const fs = require('fs');
const path = require('path');
const os = require('os');

const configDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const flagPath = path.join(configDir, '.{SKILL_NAME}-active');

let input = '';
process.stdin.on('data', d => input += d);
process.stdin.on('end', () => {
  try {
    const { prompt = '' } = JSON.parse(input);

    const isOff = /stop {SKILL_NAME}|{SKILL_NAME} off|disable {SKILL_NAME}/i.test(prompt);
    const isOn  = prompt.trim().startsWith('/{SKILL_NAME}');

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
        hookSpecificOutput: '<!-- {SKILL_NAME} ACTIVE -->'
      }));
    }
  } catch {}
});
```

---

## safeWriteFlag pattern

Atomic write, 0600 perms, symlink-safe, silent-fail. Use verbatim — don't improvise.

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

---

## plugin.json with hooks

For mode skills:

```json
{
  "name": "{SKILL_NAME}",
  "description": "{SKILL_DESCRIPTION}",
  "author": {"name": "{AUTHOR_NAME}", "url": "{AUTHOR_URL}"},
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

## plugin.json without hooks

For workflow / tool / reference / agent skills:

```json
{
  "name": "{SKILL_NAME}",
  "description": "{SKILL_DESCRIPTION}",
  "author": {"name": "{AUTHOR_NAME}", "url": "{AUTHOR_URL}"}
}
```
