# General testing philosophy

1. Respect the current repository testing strategy and existing test suite.
2. Do not add new unit tests by default.
3. When tests are needed, prefer integration, end-to-end, or smoke tests that validate real behavior.
4. Use unit tests only rarely — mainly for stable datasets or pure data transformations.
5. Never add unit tests just to increase coverage numbers.
6. Avoid mocks when real calls are practical.
7. Prefer real API or service calls over fragile mock-based coverage when cost is reasonable.
8. Add only the minimum test coverage needed for the requested change.

# Project-specific (when applicable)

1. For bugfixes, confirm the actual failing user flow against the referenced working path/file before choosing a fix or test target.
2. Before writing tests, inspect 2-3 analogous tests in the same package and mirror their framework, file location, structure, and style.
3. Do not introduce a new test runner, test style, or harness in a package without explicit user approval.
4. NEVER use `bun:test`. Always use `@effect/vitest`.
5. Do not blanket-mock all imports of a module or build large mock dependency graphs to force a test to pass. If a module cannot be imported cleanly in the test environment, stop and report the issue instead of papering over it with mocks.
6. If the idiomatic test approach is blocked by tooling or environment, stop, report the blocker, and ask before inventing a fallback.
7. Do not generate tests unless explicitly asked.
8. Do not export values solely for the purpose of testing them (e.g. `export const X = 'y'` with a test that just asserts `expect(X).toEqual('y')`). Tests must exercise user-visible behavior, not static declarations.
9. Route components must only be tested end-to-end. Do not write unit tests for route components. React components that are not routes may be unit tested.
