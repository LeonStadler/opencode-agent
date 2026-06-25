# Documentation

## When to update project documentation

Required for **major** changes when any of the following apply:

- New or changed API endpoints
- Configuration options or environment variables change
- New features or significant feature changes
- Architecture changes
- Providers added or changed
- Breaking changes introduced

Keep documentation consistent with the current state of code and configuration — not aspirational or historical.

## Inline documentation

1. Create separate documentation files only when a concept cannot be expressed clearly in code, or when logic spans files or larger cross-cutting concerns.
2. Never duplicate documentation across multiple files. Store docs in the appropriate `docs/` folder with clear structure.
3. Save knowledge as **current state**, not as a change log. Changelog belongs in `changelog.md`.

## Technical Writer scope

Documentation under `docs/**` is owned by `@Technical Writer`. Implementation agents may edit `docs/**` only when explicitly delegated.
