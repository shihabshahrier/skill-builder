# 🛠️ skill-builder

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent Skills Open Standard](https://img.shields.io/badge/Agent_Skills-Open_Standard-orange.svg)](https://agentskills.io)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Build any custom AI agent skill, prompt, or tool from a plain-English description. **One command, production-ready output.**

`skill-builder` is fully compatible with the **[Agent Skills open standard](https://agentskills.io)**, supporting major AI coding assistants and CLI agents: **Claude Code, Cursor, Cline, Windsurf, Copilot, Gemini CLI, Codex, opencode**, and 20+ others.

---

## ⚡ What it does

Instead of manually writing complex prompts, metadata, and hook templates for different agents, simply run:

```bash
/skill-builder "compress images before committing"
```

🎯 **Generates a fully scaffolded, production-ready repository:**
```text
image-compressor/
├── skills/
│   └── image-compressor/
│       ├── SKILL.md              ← Complete, validated frontmatter & body
│       └── references/
│           └── compression-api.md ← Rich domain knowledge, loaded lazily
├── install.sh                    ← Installs instantly to all 5 standard agent paths
├── README.md                     ← Auto-generated, clear documentation
└── LICENSE                       ← Standard open-source license
```

> [!TIP]
> The generated skill is immediately operational right after running `bash install.sh`. No manual configuration is required.

---

## 📦 Installation

`skill-builder` runs natively inside your agent's environment. You can install it automatically or copy files manually.

### 1. Claude Code
Install as a plugin directly:
```bash
claude plugin install shihabshahrier/skill-builder
```

### 2. Multi-Agent Setup (opencode, Cursor, Windsurf, Cline, Codex, Gemini, OpenClaw)
Clone the repository and run the unified installer to copy the skill to all agent config paths automatically:
```bash
git clone https://github.com/shihabshahrier/skill-builder.git
cd skill-builder
bash install.sh
```

### 3. Manual Installation (Specific Agents)
If you prefer manual placement, copy the skill directory to the corresponding discovery path:

*   **Claude Code:**
    ```bash
    mkdir -p ~/.claude/skills/skill-builder
    cp -r skills/skill-builder/. ~/.claude/skills/skill-builder/
    ```
*   **OpenAI Codex:**
    ```bash
    mkdir -p ~/.agents/skills/skill-builder
    cp -r skills/skill-builder/. ~/.agents/skills/skill-builder/
    ```
*   **Gemini CLI:**
    ```bash
    mkdir -p ~/.gemini/antigravity/skills/skill-builder
    cp -r skills/skill-builder/. ~/.gemini/antigravity/skills/skill-builder/
    ```

### 🔍 Verification
Verify your installation inside your agent shell:
```bash
# Inside Claude Code — ensures skill appears in the /help listing
/help

# Any Agent — run the command directly
/skill-builder "What does this skill do?"
```

---

## 🚀 Usage Guide

### 🛠️ Build a New Skill
Generate structured skills, tools, workflows, or roles using plain-English prompts.

```bash
# Simple auto-detected generation
/skill-builder "scaffold a fastapi project"

# Force a specific skill type
/skill-builder "remind the model to write unit tests first" --type reference

# Generate a complete marketplace-ready repository scaffold
/skill-builder "make the model speak formally" --type mode --repo
```

### 🔎 Audit & Repair Existing Skills
Ensure your existing skills adhere to best practices and spec compliance.

```bash
# Run the quality checklist against an existing skill
/skill-builder --audit skills/my-skill/SKILL.md

# Audit and automatically correct any non-compliant sections
/skill-builder --audit skills/my-skill/SKILL.md --fix
```

---

## ⚙️ CLI Flags Reference

| Flag | Default | Allowed Values | Description |
|:---|:---|:---|:---|
| **`description`** | *Required* | Plain-English string | High-level goal of what the skill/prompts/tools should do. *(Omit only when using `--audit`)* |
| **`--type`** | `auto` | `workflow`, `mode`, `tool`, `reference`, `agent` | Forces a specific classification (overrides automatic smart detection). |
| **`--repo`** | `false` | None | Scaffolds a full publish-ready repo directory containing the skill, README, LICENSE, agent rules, and install script. |
| **`--audit`** | `none` | Path to a `SKILL.md` | Inspects and audits the target file for compliance, performance, structure, and token budgets. |
| **`--fix`** | `false` | None | Works alongside `--audit`. Re-writes the file with fixes while leaving compliant sections untouched. |

---

## 🧩 Supported Skill Types

`skill-builder` understands the nuances of various interactive paradigms:

| Category | Description | Example Prompt |
|:---|:---|:---|
| **`workflow`** | Multi-step pipelined execution that outputs artifacts | *"Scaffold a clean FastAPI + Tailwind project"* |
| **`mode`** | Persistent behavioral instructions active on every turn | *"Always output code using strictly functional programming"* |
| **`tool`** | One-shot atomic transformation on target files/data | *"Compress CSS files and format code before committing"* |
| **`reference`** | Static, specialized domain knowledge loaded on demand | *"Include our internal API conventions and schemas"* |
| **`agent`** | A highly autonomous persona operating as a multi-role team | *"Act as a senior DevOps firm deploying to AWS"* |

---

## 🤖 Supported Agents & Ecosystem

The generated skill bundles are compatible with the industry's leading AI environments:

| Agent / Environment | Discovery Path |
|:---|:---|
| **Claude Code** | `~/.claude/skills/` |
| **OpenAI Codex** | `~/.agents/skills/` |
| **opencode (SST)** | `~/.config/opencode/skills/` (and standard fallbacks) |
| **Gemini CLI** | `~/.gemini/antigravity/skills/` |
| **OpenClaw** | `~/.openclaw/workspace/skills/` |
| **Cursor** | `.cursor/rules/` (condensed `.mdc` file formats) |
| **Windsurf** | `.windsurf/rules/` (system rules) |
| **Cline** | `.clinerules/` (custom instruction instructions) |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **Generic Agents** | `AGENTS.md` (root directory includes) |

---

## 🧠 Architectural Workflow

`skill-builder` goes through a highly efficient, multi-phase compilation pipeline:

```text
  [ Plain-English Input ]
             │
             ▼
     0. Route CLI Flags  ─────────►  [ --audit ]  ──► Phase A: Parse & Verify Target
             │                                               │ (Fix & Output if requested)
     1. Classify Type (Smart NLP)                            ▼
             │                                       [ Quality Report ]
     2. Gather Parameters (≤3 Qs)
             │
     3. Domain Research (Auto Web-search & extraction)
             │
     4. Generate SKILL.md (Strict standard validation)
             │
     5. Generate Domain References (Lazy-loaded tables & docs)
             │
     6. Generate Execution Hooks (Safe system-level JS handlers)
             │
     7. Scaffolding (Create repo structure if --repo is enabled)
             │
             ▼
      [ Done! Install & Test ]
```

---

## 🛠️ Requirements

- **None!** `skill-builder` relies purely on standard markdown templates, shell scripts, and native agent capabilities.
- No bulky runtimes, no dependencies to build, and no external package manager overhead.

---

## 🤝 Contributing

Contributions are highly welcome! To contribute:
1. Review the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines.
2. Direct your changes exclusively to the skill source: `skills/skill-builder/SKILL.md` and `skills/skill-builder/references/*.md`.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

