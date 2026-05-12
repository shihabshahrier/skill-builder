# Contributing

Improvements to the skill, references, or generated templates are welcome.

## How

1. Fork the repo
2. Edit the source file for your change:
   - **Skill behavior**: `skills/skill-builder/SKILL.md`
   - **Frontmatter spec**: `skills/skill-builder/references/skill-anatomy.md`
   - **Skill type patterns**: `skills/skill-builder/references/skill-types.md`
   - **Agent rule formats**: `skills/skill-builder/references/agent-rules.md`
   - **Install paths**: `skills/skill-builder/references/install-paths.md`
3. Open a PR with:
   - **Before**: what the skill generates now
   - **After**: what it generates with your change
   - One sentence on why the change is better

## Rules

- Install path changes require a verified source (official agent docs URL)
- Frontmatter spec changes must match the [Agent Skills open standard](https://agentskills.io)
- Hook patterns must be tested against Claude Code — silent-fail rule is non-negotiable
- Do not edit agent-specific rule files (`.cursor/`, `.windsurf/`, etc.) directly

## Ideas

See [issues](../../issues).
