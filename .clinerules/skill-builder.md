When user says `/skill-builder`, follow `skills/skill-builder/SKILL.md`.

**Invocation**: `/skill-builder "description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]`

**Phases (create)**: route → classify → gather (≤3 Qs) → domain research (WebSearch official docs) → SKILL.md → references → hooks (mode only) → repo scaffold (--repo) → report

**Phase A (--audit)**: read SKILL.md at path → run quality checklist → report failures/warnings/passed → if --fix output corrected SKILL.md

**Rules**:
- `name`: `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 chars; `description`: max 1024 chars; SKILL.md body: max 5000 tokens
- Extended Claude Code fields to include: `argument-hint`, `when_to_use`, `model`, `effort`, `context`, `agent`, `paths`
- Substitute all `{VARIABLES}` in every generated file before outputting
- Domain facts in references: WebSearch official docs first — never guess API names or flags
- Reference files >100 lines: add TOC at top; one-level-deep only
- Hook JS must use safeWriteFlag pattern and silent-fail on all filesystem errors
