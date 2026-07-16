# Changelog

All notable changes to this repository. Format follows `rules/changelog-versioning.md`.

## Version 0.5.0 — 2026-07-16

### Features

- **GPT-5.6 tiered models per agent**: Luna (lightweight), Terra (default), Sol (code/security only) with `low` / `medium` / `high` reasoning — no `max` or `xhigh`
  - **Luna**: Researcher, Doc Reviewer, DevOps Engineer
  - **Terra**: Coordinator, Code Reviewer, QA Automation Engineer, Technical Writer, PRD Critic
  - **Sol**: Software Engineer, Security Auditor
- **Coordinator permissions**: Explicit `skill`, `task`, `webfetch` allow rules

### Chores

- **Removed global model override** from `templates/opencode.*.json` — models live in agent frontmatter only
- **`README.md`**: Agent table with model, reasoning, and temperature per role

---

## Version 0.4.0 — 2026-06-25

### Features

- **Extended rules**: Changelog/versioning, documentation, code quality, programming style, error handling, tooling, and workflow guidelines (`rules/changelog-versioning.md`, `rules/documentation.md`, `rules/code-quality.md`, `rules/programming-style.md`, `rules/error-handling.md`, `rules/tooling.md`, `rules/workflow.md`)
- **Agent updates**: Release hygiene in Coordinator Phase 4; standardized bash permission syntax in Coordinator; Technical Writer references doc/changelog rules (`agents/Coordinator.md`, `agents/Technical Writer.md`)
- **`changelog.md`**: Project changelog with version history and attribution

### Docs

- **`README.md`**: Rules table, origin section crediting [Tom Kühl](https://github.com/tomkuehl), troubleshooting updates
- **Full English translation** of README, changelog, `install.sh`, `uninstall.sh`, and `templates/AGENTS.md`
- **`testing.md`**: General testing philosophy section added above project-specific rules

---

## Version 0.3.0 — 2026-06-24

### Features

- **`install.sh` / `uninstall.sh`**: One-command install and uninstall for global (`~/.config/opencode/`) and project-specific (`.opencode/`) setups
- **`templates/`**: OpenCode config templates for global (`opencode.global.jsonc`) and project (`opencode.project.json`) setups, plus `AGENTS.md` template
- **`skills/parallel-bug-audit/`**: Moved bug-audit skill from `bug-and-gap-audit/` into standard skill layout (`skills/parallel-bug-audit/SKILL.md`, `references/`)

### Chores

- **Researcher consolidated**: Removed root duplicate; canonical definition under `agents/Researcher.md`
- **Technical Writer**: `mode: subagent`, cleaned YAML frontmatter for edit permissions
- **`.gitignore`**: Extended for `.DS_Store`, `.opencode/`, IDE artifacts
- **`README.md`**: Simplified install guide and repo structure

---

## Version 0.2.0 — 2026-06-18

### Features

- **`README.md`**: Full documentation — architecture, installation, Coordinator workflow, agent overview, troubleshooting
- **`opencode.json.example`**: Example config with `default_agent: Coordinator`, disabled built-in agents, skill/task permissions (later moved to `templates/`)
- **`.gitignore`**: Initial ignore rules for secrets, OpenCode runtime, Node artifacts

---

## Version 0.1.0 — 2026-06-18

### Features

- **Agent suite (10 agents)**: Coordinator, Researcher, Software Engineer, Code Reviewer, Security Auditor, DevOps Engineer, QA Automation Engineer, Technical Writer, Doc Reviewer, PRD Critic (`agents/`)
- **Rules (3 files)**: Code style, React guidelines, testing (`rules/code-styles.md`, `rules/react-guidelines.md`, `rules/testing.md`)
- **Bug-audit skill**: Parallel subsystem audit via Researcher subagents (`bug-and-gap-audit/SKILL.md`, `references/bug-report-template.md`, `references/failure-mode-brief.md`)

> The original agent and rules scaffold for [OpenCode](https://opencode.ai) comes from [Tom Kühl](https://github.com/tomkuehl). This repository adapts and extends it and adds a Bash install script.
