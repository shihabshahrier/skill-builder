# Skill Types Reference

Five types. Pick one before writing anything. The type determines body structure,
whether hooks are needed, and how the skill is discovered.

---

## Type 1 — Workflow

**What it is**: Multi-step pipeline that produces artifacts.
**Trigger**: User-invocable (`/skill-name args`).
**State**: Stateless — each invocation is independent.
**Hooks needed**: No.
**References needed**: Usually yes (domain knowledge loaded per phase).

**Signal phrases**: "create", "generate", "scaffold", "build X from Y", "run pipeline"

**Examples**: test-manim, softco, an image-processing pipeline, a PR generator

**Body pattern**:
```
Invocation → Phase 0 (parse + scaffold) → Phase 1…N (work) → Phase N+1 (report)
```

Key rules:
- Phase 0 always: parse args, create dirs/files, never do real work
- Last phase always: structured report with what was produced
- Batch all writes before running any external tools
- Token efficiency section mandatory
- Open-weight model rules section mandatory

---

## Type 2 — Mode

**What it is**: Persistent behavior change that affects every response.
**Trigger**: Auto-activates via SessionStart hook OR user types `/skill-name`.
**State**: Stateful — flag file persists across turns.
**Hooks needed**: Yes — SessionStart + UserPromptSubmit.
**References needed**: Sometimes (for complex mode rules).

**Signal phrases**: "always", "every response", "mode", "persistently", "change how you talk/write"

**Examples**: caveman, a formal-English mode, a rubber-duck-debug mode, a socratic-teaching mode

**Body pattern**:
```
Activation → Persistence → Rules → Intensity Levels → Auto-Clarity → Boundaries
```

Key rules:
- Must define ON/OFF triggers (both natural language and slash command)
- Auto-Clarity section: when to drop mode (security warnings, destructive ops, user confused)
- Boundaries section: what never changes regardless of mode (code, commits, PRs)
- Hook writes flag file via `safeWriteFlag` pattern (atomic write, 0600 perms, no symlinks)
- Per-turn UserPromptSubmit hook reinforces mode so it doesn't drift

**Flag file pattern**:
```
$CLAUDE_CONFIG_DIR/.{skill-name}-active   (falls back to ~/.claude/.)
```

---

## Type 3 — Tool

**What it is**: Single action applied to a specific target — takes input, produces output.
**Trigger**: User-invocable (`/skill-name target`).
**State**: Stateless.
**Hooks needed**: No.
**References needed**: Sometimes (domain-specific processing rules).

**Signal phrases**: "compress", "format", "lint", "convert", "validate", "summarize X"

**Examples**: caveman-compress, caveman-commit, caveman-review, an image-optimizer,
  a SQL formatter, a commit-message generator

**Body pattern**:
```
Trigger → Process (numbered steps) → Output → Error Handling
```

Key rules:
- Process steps must be atomic and ordered
- Output section: exactly what is produced, where it goes, filename conventions
- Error handling: what to do when tool/script fails (retry count, fallback, user message)
- If tool runs scripts: include scripts/ directory with the implementation
- Keep it simple — a tool does one thing

---

## Type 4 — Reference

**What it is**: Domain knowledge that shapes how the model approaches a subject area.
**Trigger**: Auto-triggers when relevant content detected, OR user loads explicitly.
**State**: Stateless.
**Hooks needed**: No (or optional SessionStart to pre-load).
**References needed**: It IS a reference — structure knowledge inside the skill itself.

**Signal phrases**: "remind", "remember", "context for", "know about", "best practices for",
  "when working on X always", "rules for"

**Examples**: A security checklist skill, a project-specific coding standards skill,
  a domain glossary, a "when working on React always do X" skill

**Body pattern**:
```
Purpose → When to Apply → {Domain Section 1} → {Domain Section N} → Never Do
```

Key rules:
- Content-dense: tables, bullet lists, code examples — minimal prose
- "When to Apply" section is critical: exact trigger conditions so model knows when active
- "Never Do" section: the anti-patterns, makes it easy to check compliance
- No phases — this isn't a pipeline, it's context

---

## Type 5 — Agent

**What it is**: Autonomous persona that occupies multiple roles and drives a project.
**Trigger**: User-invocable, but then operates autonomously across many steps.
**State**: Semi-stateful — uses PROGRESS.md / TodoWrite to track state across turns.
**Hooks needed**: No (but benefits from SessionStart for context pre-load).
**References needed**: Yes, many — loaded per phase.

**Signal phrases**: "act as", "autonomous", "company", "firm", "expert in", "manage the whole"

**Examples**: softco, a full-stack dev agent, a research agent, a data-science pipeline agent

**Body pattern**:
```
Persona description → Prime Directive → Mode Detection →
Phase table → Phase 0…N detail → Prohibited Actions → Success Criteria
```

Key rules:
- Prime directive: one sentence — the non-negotiable goal
- Mode detection table: what signal → what mode → what phase to enter
- Questions protocol: max 3 per turn, grouped by theme, wait before next batch
- Progress tracking: TodoWrite or PROGRESS.md kanban
- AGENT.md contract: every project ships an AGENT.md for future sessions to continue
- Prohibited actions section is hard stops — the model pushes back once, complies with override

---

## Decision Tree

```
Does it change behavior permanently across all responses?
  YES → Mode (type 2)
  NO ↓

Does it do one atomic thing to one target?
  YES → Tool (type 3)
  NO ↓

Does it load knowledge to guide behavior on a subject area?
  YES → Reference (type 4)
  NO ↓

Does it produce artifacts through a multi-step pipeline?
  YES → does it orchestrate roles autonomously over a long session?
    YES → Agent (type 5)
    NO  → Workflow (type 1)
```

---

## Hybrid Skills

Some skills combine types. Handle by picking the primary type and adding secondary behavior:

| Combination | Example | Approach |
|-------------|---------|----------|
| Mode + Tool | caveman + caveman-commit | Separate skills in same repo, each with own SKILL.md |
| Workflow + Reference | softco (loads many refs per phase) | Workflow primary, refs lazy-loaded |
| Tool + Scripts | caveman-compress (runs python scripts) | Tool primary, add scripts/ dir |
| Agent + References | softco | Agent primary, reference loading in phase instructions |

Never try to make one SKILL.md do two primary types — split into separate skills.
