# Failure-mode brief — how to build it

Reference for the `parallel-bug-audit` skill (Phase 2). The brief is a
**per-audit** document: the catalogue of bug classes the target subsystem is
prone to, assembled fresh each time so the skill stays domain-agnostic. This
file tells you how to build one, what to seed it from, and how to turn it into
disjoint angles.

## Contents

- [How to build it](#how-to-build-it)
- [What the brief contains](#what-the-brief-contains)
- [Seed lens menu (generic starting point)](#seed-lens-menu-generic-starting-point)
- [Turning the brief into angles](#turning-the-brief-into-angles)
- [Worked carving examples](#worked-carving-examples)

---

## How to build it

Cheap by default, deep only when it pays:

1. **Knowledge-first.** Name the dominant failure classes for this kind of
   subsystem from what you already know. For common targets this is the whole
   brief and costs nothing.
2. **Web-fetch when invariants must be exact.** Only when the domain is
   unfamiliar, fast-moving, or spec-precise — a specific API's quirks/limits, a
   protocol's edge cases, a library's known-bug list. Prefer primary sources
   (official docs, the spec, the library's issue tracker) over listicles. Pull
   the _specific invariant_, not a generic "common bugs" page.
3. **Read code, then ask — only when blocked.** Answer open questions from the
   implementation first. Ask the user only when the answer changes the whole
   audit and isn't in the code (e.g. intended delivery semantics, whether a
   field is authoritative locally or upstream).

Persist the result to a worktree scratch file (e.g.
`.opencode/.cache/bug-audit/<target>-failure-modes.md`) so every dispatched
Researcher can read the same brief. Keep it transient/gitignored.

---

## What the brief contains

Structure it so each entry maps cleanly to an angle later:

```
# Failure-mode brief — <target>

## Context (from Phase 1)
- Source of truth: ...
- State / persistence: ...
- Concurrency: what can run at once
- External dependencies / trust boundaries: ...
- Delivery / consistency semantics (if known or assumed): ...

## Failure classes
For each class the target is prone to:
- **<class name>** — what can go wrong here, the specific footguns for THIS
  target, and red flags to grep for. Cite the source if web-fetched.

## Open questions
- Anything unresolved that a Researcher should try to answer from the code.
```

Keep footguns concrete ("cursor advanced before the batch commits → crash loses
the batch") rather than vague ("check error handling"). Concrete entries are
what make a Researcher's hunt productive.

---

## Seed lens menu (generic starting point)

These domain-agnostic lenses are a _seed_ — the brief enriches the relevant ones
with target-specific footguns and drops the irrelevant ones. They're also the
default angle set when a target doesn't decompose obviously.

- **State & invariants** — What must always be true? Where can it be violated?
  Source of truth, consistency between redundant representations, drift,
  corruption, stale reads.
- **Inputs & boundaries** — Empty, null/undefined, zero, negative, max, malformed,
  huge, unicode/encoding. Off-by-one. Validation that doesn't reject.
- **Error handling & partial failure** — Failure mid-operation: swallowed errors,
  missing rollback, half-applied state, resource cleanup on the error path, crash
  points, atomicity of multi-step writes.
- **Concurrency & ordering** — Races, shared mutable state, lock discipline (and
  release on error), ordering/causality assumptions, reentrancy, lost updates.
- **Side effects, idempotency & retries** — Replays and retries, dedup keys,
  side effects firing twice, delivery semantics (at-least-once vs exactly-once),
  poison records / head-of-line blocking.
- **External dependencies & trust boundaries** — Dependency slow/down/rate-
  limited/returning garbage/schema-changed; auth & token lifecycle (refresh,
  expiry, revocation); untrusted input crossing the boundary.
- **Resource lifecycle** — Leaks (connections, handles, memory), unbounded
  growth, buffering large data into memory, backpressure, timeouts.
- **Misleading implementations** _(cross-cutting — every Researcher applies it)_ —
  behavior that diverges from name/comment/contract: silent caps, swallowed
  errors, no-op guards, stale/aspirational comments, reachable TODO/stub paths,
  dead branches.

---

## Turning the brief into angles

Carve so coverage is **additive** and overlap minimal. Pick the decomposition
that yields the most disjoint angles for this target — often a combination:

- **By data-flow stage** — ingest → transform → persist → emit. Clean when the
  subsystem is a pipeline.
- **By responsibility / module** — one cohesive component per angle. Clean when
  the code is well-separated.
- **By failure class** — assign each relevant lens above as an angle. Clean when
  the code is tangled and stages/modules aren't separable.
- **By trust boundary** — each point where data/control crosses in. Clean for
  integrations and security-sensitive surfaces.

Scale count to size: small handler 3–4, full engine 6–7. Keep angles disjoint —
if two would read mostly the same code, merge or re-cut them.

---

## Worked carving examples

Illustrative angle sets — a starting point to adapt, not a fixed answer.

**Sync engine** — state & reconciliation · incremental cursors & deltas ·
idempotency & retries · ordering, deletes & tombstones · partial-failure &
resumability · concurrency & races · upstream protocol & limits.

**Auth / session flow** — credential & token issuance · session/token validation
· refresh & expiry · revocation & logout · concurrency (parallel refresh, fixation)
· input validation & trust boundary.

**Parser / serializer** — malformed & adversarial input · boundary sizes,
encodings & escaping · round-trip fidelity (parse∘serialize) · resource
exhaustion (huge / deeply-nested input) · error propagation vs silent acceptance.

**Job scheduler / queue consumer** — delivery semantics & dedup · ordering &
priority · retry/backoff & poison messages · concurrency & locking · crash &
resume · backpressure & resource limits.

**Cache layer** — invalidation correctness · staleness & TTL · stampede /
thundering herd · consistency with source of truth · key collisions & scoping ·
memory growth & eviction.

Each example is just the seed lenses specialized to the domain. Build the brief
first; the angles fall out of it.
