1. For bugfixes, confirm the actual failing user flow against the referenced working path/file before choosing a fix or test target.
2. Before writing tests, inspect 2-3 analogous tests in the same package and mirror their framework, file location, structure, and style.
3. Do not introduce a new test runner, test style, or harness in a package without explicit user approval.
4. NEVER use `bun:test`. Always use `@effect/vitest`.
5. Do not blanket-mock all imports of a module or build large mock dependency graphs to force a test to pass. If a module cannot be imported cleanly in the test environment, stop and report the issue instead of papering over it with mocks.
6. If the idiomatic test approach is blocked by tooling or environment, stop, report the blocker, and ask before inventing a fallback.
7. Do not generate tests unless explicitly asked.
8. Do not export values solely for the purpose of testing them (e.g. `export const X = 'y'` with a test that just asserts `expect(X).toEqual('y')`). Tests must exercise user-visible behavior, not static declarations.
9. Route components must only be tested end-to-end. Do not write unit tests for route components. React components that are not routes may be unit tested.
