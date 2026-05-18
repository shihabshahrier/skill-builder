# CLAUDE.md — skill-builder

## What this repo is

skill-builder is a workflow skill for AI coding agents. One purpose: turn a plain-English
description into a production-ready skill compatible with the Agent Skills open standard.

---

## Source of truth — edit only these

| File | Controls |
|------|----------|
| `skills/skill-builder/SKILL.md` | All skill behavior: phases, detection, templates |
| `skills/skill-builder/references/skill-anatomy.md` | Universal frontmatter spec |
| `skills/skill-builder/references/skill-types.md` | Type taxonomy + decision tree |
| `skills/skill-builder/references/agent-rules.md` | All agent file formats + hook patterns |
| `skills/skill-builder/references/install-paths.md` | All agent discovery paths |

**Never edit agent-specific files directly.** They are condensed summaries of the source files.
When source files change, update the agent-specific copies manually.

## Agent-specific files (condensed summaries — sync when source changes)

| File | Agent |
|------|-------|
| `.cursor/rules/skill-builder.mdc` | Cursor |
| `.windsurf/rules/skill-builder.md` | Windsurf |
| `.clinerules/skill-builder.md` | Cline |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `.codex/hooks.json` | OpenAI Codex |
| `AGENTS.md` | OpenAI Agents SDK / Jules / any AGENTS.md reader |
| `GEMINI.md` | Gemini CLI |

---

## Key constraints

- **Universal first**: SKILL.md frontmatter must use standard fields (`name`, `description`).
  Claude Code-specific fields (`user-invocable`) come after.
- **Install paths must be verified**: only add paths from official agent documentation.
- **Hook patterns must silent-fail**: any hook error that propagates blocks Claude Code session start.
- **No invented APIs**: all agent file formats in `agent-rules.md` verified against live docs.

---

## Agent Skills open standard

Released December 2025 by Anthropic. Adopted by 32+ tools within 90 days.
Spec: https://agentskills.io

Key constraints from spec:
- `name`: `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 chars
- `description`: max 1024 chars
- Universal fields: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`
- Agent-specific fields: ignored by non-matching agents

---

## Making changes

1. Edit source file
2. Update agent-specific condensed copies if the change affects critical constraints
3. Run `bash install.sh` to push to all local agent paths
4. Test with `/skill-builder "test description"` in Claude Code
5. Open PR with before/after example
