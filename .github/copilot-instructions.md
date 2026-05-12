When user says `/skill-builder`, follow `skills/skill-builder/SKILL.md`.

**Invocation**: `/skill-builder "description" [--type workflow|mode|tool|reference|agent] [--repo] [--audit path] [--fix]`

**8 phases (create)**: route → classify type → gather requirements (≤3 Qs) → domain research (WebSearch official docs for every tool/API the skill references) → generate SKILL.md → generate references → generate hooks (mode only) → scaffold full repo (--repo) → report with install commands

**Phase A (--audit)**: read existing SKILL.md → run quality checklist from `references/skill-anatomy.md` → report [FAIL]/[WARN]/passed → if --fix output corrected SKILL.md (fix failures only)

**Universal SKILL.md frontmatter**: `name` (`^[a-z0-9]+(-[a-z0-9]+)*$`, max 64), `description` (max 1024), `license`, `compatibility`, `metadata`, `allowed-tools`

**Claude Code / opencode extended fields** (after universal): `user-invocable`, `disable-model-invocation`, `argument-hint`, `when_to_use`, `model`, `effort`, `context`, `agent`, `paths`, `shell`, `hooks`

**Substitute all `{VARIABLES}`** in every generated file. Never leave raw placeholders.

**Domain research required** — WebSearch official docs before writing any reference files. Never guess CLI flags, API method names, or config schemas.

**Size budgets**: SKILL.md body ≤5000 tokens. Reference files >100 lines need TOC at top. References one-level-deep only.

Load `skills/skill-builder/references/skill-types.md` at Phase 0.
Load `skills/skill-builder/references/agent-rules.md` at Phase 7 (hooks/repo) only.
Load `skills/skill-builder/references/install-paths.md` at Phase 8 only.
