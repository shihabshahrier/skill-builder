# Skill Anatomy Reference

Complete spec for writing a correct SKILL.md. Based on the Agent Skills open standard
(released December 2025, adopted by 32+ tools).

---

## Progressive Disclosure Model

Agents load skills in 3 stages. Design for this:

| Stage | What loads | When | Token budget |
|-------|-----------|------|-------------|
| 1 | `name` + `description` only | Every session startup | ~100 tokens |
| 2 | Full `SKILL.md` body | When skill is invoked | **≤5000 tokens** |
| 3 | `references/*.md` files | On-demand, per phase | Per-file as needed |

**SKILL.md must stay under 5000 tokens.** Move dense domain knowledge to `references/`.
Reference files >100 lines must have a table of contents at the top so the model sees full scope.
References must be one-level-deep only — no chained includes.

---

## Universal Frontmatter (all agents)

```yaml
---
name: skill-name          # REQUIRED. 1–64 chars. ^[a-z0-9]+(-[a-z0-9]+)*$
description: >            # REQUIRED. 1–1024 chars. First line answers "what does it do?"
  Line 1: verb + object   # shown in skill listings and /help
  Line 2: how invoked
  Line 3: key output
  Line 4: compatibility or use case
license: MIT              # OPTIONAL. any SPDX identifier
compatibility: ">=1.0"    # OPTIONAL. semver range for skill spec version
metadata:                 # OPTIONAL. string-to-string map, arbitrary key-value
  author: "your-name"
  category: "productivity"
allowed-tools:            # OPTIONAL. restrict which agent tools skill may call
  - bash
  - read
  - write
---
```

**Unknown fields are silently ignored** by all compliant agents — safe to add agent-specific fields.

---

## Claude Code / opencode Extended Frontmatter

Add after universal fields. All fields optional.

```yaml
# Invocation control
user-invocable: true              # user types /skill-name to invoke
disable-model-invocation: true    # agent won't self-trigger on unrelated tasks

# Argument handling
argument-hint: '"description" [--type workflow|mode|tool|reference|agent] [--audit path]'
arguments:                        # named positional args — use $arg_name in skill body
  - name: description
    description: plain-English description of what the skill should do
    required: true
  - name: type
    description: skill type override
    required: false

# Response shaping
model: sonnet                     # override model: haiku | sonnet | opus
effort: high                      # thinking budget: low | medium | high | xhigh | max
context: fork                     # run in isolated subagent (no shared context)
agent: general-purpose            # subagent type: Explore | Plan | general-purpose

# Trigger scoping
when_to_use: >                    # extra trigger keywords appended to description
  Use when user says build a skill, create a skill, make a skill, /skill-builder.
paths:                            # only activate when cwd matches these globs
  - "skills/**"
  - "*.skill.md"

# Runtime
shell: bash                       # bash | powershell (for command injection in scripts)
hooks:                            # lifecycle hooks declared in frontmatter
  pre-invoke: scripts/setup.sh
  post-invoke: scripts/cleanup.sh
```

**Combining flags:**
- `user-invocable: true` + `disable-model-invocation: true` = user-only, Claude never auto-invokes
- Omit both = Claude auto-decides when to invoke based on `description` + `when_to_use`
- `context: fork` = skill runs in isolated subagent, can't pollute main context window
- `effort: xhigh` or `max` = extended thinking enabled, use for complex generation tasks

---

## Codex only (in `agents/openai.yaml`, not in SKILL.md)

```yaml
interface:
  display_name: "Skill Display Name"
  short_description: "One punchy sentence."
policy:
  allow_implicit_invocation: false  # true = Codex auto-invokes when relevant
```

---

## `name` Validation

Must match: `^[a-z0-9]+(-[a-z0-9]+)*$`

| Valid | Invalid |
|-------|---------|
| `skill-builder` | `SkillBuilder` |
| `test-manim` | `test_manim` |
| `my-tool-v2` | `my tool` |
| `codegen` | `2cool-skill` |

---

## `description` Writing

First line must answer "what does it do?" in ≤80 chars.

Pattern:
```
Line 1: [verb] [object] [context]
Line 2: [how invoked or trigger]
Line 3: [key constraint or behavior]
Line 4: [output, use case, or compatibility]
```

Wrong: "This skill helps you with creating animations using ManimGL..."
Right: "Create teaching-quality STEM animations using ManimGL."

Total length must be ≤1024 chars. Count before writing.

---

## Body Structure Principles

### Opening line
First line after frontmatter = one sentence. What the skill does. Not how.

Wrong: "This skill helps you by providing..."
Right: "Produce teaching-quality STEM animations in ManimGL."

### Section depth
`##` for top-level. `###` for sub-sections. Never `####`. Max 3 levels.

### Required sections by type

| Skill type | Required sections |
|------------|-------------------|
| workflow | Invocation, Phase 0…N, Token Efficiency Rules, Open-Weight Model Rules |
| mode | Activation, Persistence, Rules, Auto-Clarity, Boundaries |
| tool | Trigger, Process, Output, Error Handling |
| reference | Purpose, When to Apply, {Domain Sections}, Never Do |
| agent | Prime Directive, Mode Detection, Phases, Prohibited Actions, Success Criteria |

### Invocation table (workflow + tool)
```markdown
| Arg | Default | Values |
|-----|---------|--------|
| required-arg | — | description |
| --optional | default | options |
```

### Reference loading
Always lazy. Place at the phase that needs it:
```
Load `references/{name}.md` before {action}.
```

Reference file rules:
- One-level-deep only — reference files must not include other reference files
- Add table of contents at top of any reference file >100 lines
- Use input/output example pairs, not just descriptions
- No time-sensitive info — or isolate in an "old patterns / deprecated" section

### Template variables
`{UPPER_SNAKE}` = model must substitute at generation time.
Never output raw `{VARIABLE}` in a final file.

---

## Optional Directories

```
skills/{name}/
  SKILL.md              ← required. Keep under 5000 tokens.
  references/           ← domain knowledge, loaded lazily
    {topic}.md          ← add TOC if >100 lines
  scripts/              ← executable code the skill runs
    {script}.py
    {script}.sh
  assets/               ← static files used in skill output
    {file}
```

---

## Quality Checklist

### Spec compliance
- [ ] `name` matches directory name exactly
- [ ] `name` passes `^[a-z0-9]+(-[a-z0-9]+)*$`
- [ ] `description` first line answers "what does it do?" in ≤80 chars
- [ ] `description` total ≤1024 chars
- [ ] `user-invocable` / `disable-model-invocation` set appropriately (Claude Code / opencode only)
- [ ] `argument-hint` present if skill takes arguments
- [ ] No `{VARIABLE}` placeholders left in output

### Body quality
- [ ] First sentence of body is one line, action-oriented
- [ ] Every section is actionable — no vague guidance
- [ ] Code templates for any code the skill generates
- [ ] Error tables for any external tool calls
- [ ] Reference load instructions appear at the phase that needs them (not upfront)
- [ ] Token efficiency section in all multi-step skills
- [ ] Open-weight model rules section in all workflow/tool/agent skills
- [ ] SKILL.md body under 5000 tokens total

### Reference quality
- [ ] Reference files one-level-deep only (no chained includes)
- [ ] Reference files >100 lines have table of contents at top
- [ ] Input/output example pairs in references (not just descriptions)
- [ ] No time-sensitive info without "deprecated" label

### Production readiness
- [ ] Tested with at least 2 model sizes (e.g. haiku + sonnet)
- [ ] Doesn't break other installed skills (coexistence test)
- [ ] Domain knowledge in references verified against official docs (not guessed)

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `name` has underscores or uppercase | Use hyphens, lowercase only |
| `description` starts "This skill..." | Start with a verb or noun |
| Loading all refs at skill start | Load lazily per phase |
| Vague instruction: "write good code" | Specific: "keep construct() under 80 lines" |
| Phase 0 does real work | Phase 0 only parses args and creates dirs |
| Last phase not a report | Add Phase N — Report |
| `{VARIABLES}` left in generated output | Substitute all before writing |
| `description` over 1024 chars | Trim — agents may truncate |
| Missing `user-invocable` on Claude Code skill | Add it or model may not list skill |
| SKILL.md over 5000 tokens | Move dense content to references/ |
| Reference file has no TOC and is >100 lines | Add TOC section at top |
| References load other references | Flatten — one level only |
| Domain facts guessed, not verified | WebSearch official docs before writing refs |
| Missing `argument-hint` on skills with args | Add it — improves autocomplete UX |
