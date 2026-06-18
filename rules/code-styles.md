1. Do not extract code into new files unless explicitly asked or the code is reused by 2+ files in the codebase. Single-use helpers, types, and utilities must be co-located in the file that uses them, regardless of length.
2. Do not extract single-use logic into named helper functions within the same file unless it significantly improves readability. Simple transformations like .map(), .filter(), or short pipelines should be inlined at the call site
3. Avoid 'effect/Match' when it is only acting as a verbose substitute for `if`/`else`. Use 'effect/Match' when the code is genuinely pattern matching: matchon on `_tag`, discriminated unions, literal values, or exhaustive value-to-value mappings.
4. Avoid using tacit (point-free) function calls, such as `Effect.map(fn)`, always write function calls explicitly (`Effect.map((x) => fn(x))`).
5. Do not add useless type assertions. Only add them when they are necessary to satisfy the type checker.
6. If a type is only used to call and implement one workflow/job/API boundary, define it at that boundary and export/reuse it from there.
7. Only promote a contract to a shared package when 2+ independent consumers truly need the same abstraction.
8. Before proposing a new read endpoint, first check whether the repo already has a collection/store/query interface for that entity.
9. Prefer extending the existing collection/store/query interface over introducing a second transport.
10. If two consecutive mutations target the same object and the second only fills fields already known at the first call site, stop and collapse them into one mutation unless there is a correctness reason not to.
11. Do not re-encode guarantees that already exist upstream. If a property is already guaranteed by Schema, RPC, generated route types, or an owning abstraction, do not add casts, guards, duplicate fields, or fallback checks downstream unless you are handling a real boundary that escapes that guarantee.
