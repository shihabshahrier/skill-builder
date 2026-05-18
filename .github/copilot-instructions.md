When user says `/skill-builder`, follow `skills/skill-builder/SKILL.md`.

**Invocation**: `/skill-builder "description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]`

**9 phases (create)**: route → classify → gather (≤3 Qs) → domain research (WebSearch official docs) → generate SKILL.md → generate references → generate hooks (mode only) → scaffold repo (--repo) → report

**Phase A (--audit)**: read SKILL.md → run quality checklist → report [FAIL]/[WARN]/passed → if --fix output corrected SKILL.md

**Frontmatter**: `name` (`^[a-z0-9]+(-[a-z0-9]+)*$`, max 64), `description` (max 1024), `license`, `allowed-tools`, `metadata`

**Claude Code extended fields**: `user-invocable`, `disable-model-invocation`, `argument-hint`, `when_to_use`, `model`, `effort`, `context`, `agent`, `paths`, `shell`, `hooks`

**Size budgets**: SKILL.md ≤5000 tokens. Reference files >100 lines need TOC. References one-level-deep only.

**Domain research required** — WebSearch official docs before writing reference files. Never guess.

Load `references/skill-types.md` at Phase 1. Load `references/hook-templates.md` at Phase 6. Load `references/scaffold-templates.md`, `references/agent-rules.md`, `references/install-paths.md` at Phase 7.
