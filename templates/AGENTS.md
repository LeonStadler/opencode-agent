# OpenCode Agent Suite

Always start with `@Coordinator` — central interface for research, planning, audit, and execution.

- **Coordinator** — primary agent, orchestrates everything
- **Scout** — read-only repository map for quick orientation
- **Researcher** — read-only codebase research (delegated by Coordinator)
- **Verifier** — independently checks reports and evidence
- **CI Engineer** — owns CI pipeline definitions
- **Git Operator** — performs only explicitly authorized Git actions
- **Advisor / Security Advisor** — second opinions on major plans or unresolved high-impact security findings
- **parallel-bug-audit** — skill for parallel bug/gap audits
- **Rules** — coding conventions in `rules/`

Do not start directly with Software Engineer or similar except for targeted one-off tasks.
