# Programming Style

General defaults. Project-specific rules in `code-styles.md`, `react-guidelines.md`, and `docs/_invariants/` take precedence when they conflict.

1. Prefer functional programming over OOP.
2. Use OOP classes only for connectors and interfaces to external systems.
3. Write pure functions — modify only return values, never input parameters or global state.
4. Follow DRY, KISS, and YAGNI.
5. Use strict typing everywhere — function returns, variables, collections.
6. Check whether logic already exists before writing new code.
7. Avoid untyped variables and generic types when a concrete type is known.
8. Never use default parameter values — make all parameters explicit.
9. Create proper type definitions for complex data structures.
10. All imports at the top of the file.
11. Write simple single-purpose functions — no multi-mode behavior, no flag parameters that switch logic.
