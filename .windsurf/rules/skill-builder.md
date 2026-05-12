---
trigger: manual
---

When user says `/skill-builder`, follow `skills/skill-builder/SKILL.md`.

**Invocation**: `/skill-builder "description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]`

**Phases (create)**: route → classify → gather (≤3 Qs) → domain research (WebSearch official docs) → SKILL.md → references → hooks (mode only) → repo scaffold (--repo) → report

**Phase A (--audit)**: read existing SKILL.md → run quality checklist → report failures/warnings → if --fix output corrected file

**Critical**:
- `name`: `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 chars
- `description`: max 1024 chars; SKILL.md body: max 5000 tokens
- Extended Claude Code fields: `argument-hint`, `when_to_use`, `model`, `effort`, `context`, `agent`, `paths`
- Substitute all `{VARIABLES}` — never leave placeholders in output
- Domain facts: WebSearch official docs before writing references — never guess
- Reference files >100 lines: add TOC at top; no chained includes
