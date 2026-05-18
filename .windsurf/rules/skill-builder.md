---
trigger: manual
---

When user says `/skill-builder`, follow `skills/skill-builder/SKILL.md`.

**Invocation**: `/skill-builder "description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]`

**Phases (create)**: route → classify → gather (≤3 Qs) → domain research → SKILL.md → references → hooks (mode only) → scaffold (--repo) → report

**Phase A (--audit)**: read SKILL.md → run quality checklist → report failures/warnings → if --fix output corrected file

**Critical**:
- `name`: `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 chars; `description`: max 1024 chars; SKILL.md: max 5000 tokens
- Domain facts: WebSearch official docs before writing references — never guess
- Reference files >100 lines: TOC at top; one-level-deep only
