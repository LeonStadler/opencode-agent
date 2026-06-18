1. Composition first. Always start with the most basic primitive and build up from there.
2. Use existing `packages/ui` primitives first.
3. Do not add feature-specific wrappers unless they remove repeated complexity across 2+ real consumers.
4. Match known-good in-repo usage before inventing a new composition pattern.
5. Do not reimplement shared interactions like menus, popovers, dialogs, or drag behavior if a shared primitive already exists.
6. Interactive behavior must be explicit and predictable.
7. Default state, placement, trigger behavior, focus behavior, and any snap/resting behavior must be clear from the API and usage.
8. Prefer accessible shared primitives over bespoke interaction logic.
9. Every new shared component must have a story or a real consumer that shows the canonical usage pattern.
10. We are using React 19 and React Compiler. Use the latest features and patterns.
