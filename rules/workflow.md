# Repository Workflow

1. Inspect the repository before editing.
2. Read active `AGENTS.md` and relevant `rules/` files before making assumptions.
3. Keep changes minimal and directly related to the current request.
4. Match existing repository style even when it differs from personal preference.
5. Do not revert unrelated changes.
6. Prefer `rg` for code search.
7. Use non-interactive commands with flags.
8. Always use non-interactive git diff: `git --no-pager diff` or `git diff | cat`.
9. Run relevant tests or validation commands after code changes when the project defines them.
10. Always use branches for features and bug fixes — never commit directly to main unless explicitly instructed.
11. Create or update issues; map commits and pull requests to issues for traceability.
12. If an issue is well-formulated but needs additional context, **comment** on it — do not rewrite the issue body. Use sub-issues, parent issues, tags, and priorities for structure.
