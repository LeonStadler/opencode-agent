# Changelog & Versioning

Applies to **major** functional changes (bug fixes, enhancements, new features). Minor changes do not require changelog entries.

## Changelog

1. Record all qualifying changes in full in `changelog.md`.
2. Use these categories — never mix them ambiguously:
   - **Fixes** — bug fixes
   - **Features** — new functionality
   - **Breaking Changes** — when applicable
   - **Docs** — documentation-only changes
   - **Chores** — refactoring, dependencies, tooling
3. Each entry must document modified or newly created files and the specific functionality, **always with date** (`YYYY-MM-DD`).
4. Write changelog entries and version bump **at the end**, after all changes are successfully implemented and tested — not mid-task.

## Version bump (after changelog)

- **Bugfix** → patch: **+0.0.1**
- **Feature** → minor: **+0.1.0** (next 0.1 increment)
- **Major update** (branch merge, multiple features, major overhaul) → **+0.2.0** or as agreed with the user
- **Never set 1.0.0 on your own** — versions ending in 1.0.0 require explicit user announcement/approval

## Coordinator responsibility

At Phase 4 completion, if the work qualifies as a major change, explicitly state whether `changelog.md` and version files need updating. Do not skip this silently.
