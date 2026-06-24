---
name: parallel-bug-audit
description: >-
  Audit a subsystem for real bugs and gaps by fanning out multiple read-only
  Researcher subagents across disjoint investigation angles, then consolidating
  their findings into one verified, evidence-backed list. Use this whenever the
  user wants to review/audit an implementation for correctness — e.g. "review
  the email sync", "find the bugs and gaps in X", "what's actually wrong with
  this sync/pipeline/handler", "audit the <subsystem> implementation", or any
  request to maximize surface area on potential bugs or misleading
  implementations before changing code. Prefer this over a single-pass read
  whenever the subsystem is non-trivial (sync engines, data pipelines, retry
  logic, schedulers, parsers, state machines, anything stateful or concurrent),
  even if the user does not say the words "parallel" or "subagent".
compatibility: opencode
metadata:
  role: orchestrator
  produces: bug-and-gap-report
  subagent: Researcher
---

# Parallel Bug Audit

You are the **coordinator**. Your job is to produce a single, deduplicated,
verified list of the **actual bugs and gaps** in a target subsystem — not a
description of how the code works, and not a pile of speculative concerns.

You do this by carving the subsystem into **disjoint investigation angles** and
dispatching one **read-only Researcher subagent per angle** via the `task` tool.
Parallel, independent investigations widen the surface area you cover and reduce
the chance that one reading frame blinds the whole audit to a class of bug.

This skill is **domain-agnostic**. It carries the _method_, not a fixed bug
checklist — the domain knowledge is assembled per-audit in Phase 2, so it works
the same on a sync engine, an auth flow, a parser, or a scheduler.

> **Prerequisites.** Expects a `Researcher` subagent (`mode: subagent`,
> read-only) and `task` permission for the current agent. If no `Researcher`
> exists, fall back to the built-in read-only `explore` subagent (or `general`
> if broader tool access is needed). Keep every dispatched agent read-only —
> investigators must not edit code.

---

## The five phases

1. **Map** the subsystem so the audit is grounded in its real layout.
2. **Brief** — build a target-specific failure-mode brief (the bug classes this
   _kind_ of subsystem is prone to).
3. **Carve** 4–7 disjoint angles from the brief.
4. **Dispatch** one Researcher per angle, each with a self-contained prompt.
5. **Consolidate & verify** the reports into one classified bug/gap list.

Do not skip phases 1–2. Carving angles before you know the layout and the
failure surface produces overlapping researchers (wasted budget) and uncovered
surface (missed bugs).

---

## Phase 1 — Map the subsystem (do this yourself, fast)

Build a thin map so angles can be carved by responsibility, not guessed. Stay
shallow — you are drawing boundaries, not auditing.

- Locate the subsystem: entry points, the files/modules it spans, what it talks
  to, where it persists state. Use `grep`/`glob`/`explore` — don't hunt bugs yet.
- Note the **architecture seams**: source of truth, where state lives, trust
  boundaries, what runs concurrently, what retries.
- Capture a short inventory: `path/to/file.ts` → one line on its role. You'll
  paste the relevant slice into each Researcher's prompt so it doesn't have to
  rediscover the layout.

If the target is ambiguous ("review the sync" but there are three sync paths),
resolve it now — name the specific module, or ask — rather than guessing.

---

## Phase 2 — Build the failure-mode brief

Assemble a **target-specific failure-mode brief**: the catalogue of bug classes
that _this kind of subsystem_ is prone to. It's the fuel for everything
downstream — angles are carved from it and every Researcher hunts against it.
Built per-audit, not hardcoded, so the skill stays general while the hunt stays
sharp.

Build it **code-first and cheaply by default**, escalating only when it pays:

1. **Start from what you already know.** For common subsystems — sync, auth,
   schedulers, parsers, queues, caches — you know the dominant failure classes.
   Write them down. Usually enough, costs nothing.
2. **Web-fetch only when the domain is unfamiliar, fast-moving, or spec-precise.**
   Use `webfetch` when exact invariants matter and you're not certain of them — a
   specific API's quirks and rate-limit semantics, protocol edge cases (OAuth
   refresh, IMAP `UIDVALIDITY`, a wire format), a library's known-bug list. For
   well-trodden domains, skip it: quick searches return shallow listicles weaker
   than what you already know.
3. **Read the code, then ask — only when genuinely blocked.** Resolve open
   questions by reading the implementation first. Ask the user only when
   something _changes the whole audit_ and can't be read off the code (e.g. "is
   this pipeline meant to be exactly-once or at-least-once?"). Default to not
   interrogating.

**Persist the brief to a scratch file** in the worktree, e.g.
`.opencode/.cache/bug-audit/<target>-failure-modes.md`. This matters
mechanically: dispatched Researchers run in isolated sessions and can't see your
context, but they _can_ read a worktree file — so the brief becomes the single
shared reference they all hunt against, instead of being duplicated into every
prompt. A worktree-relative path avoids needing `external_directory` permission;
the file is transient and can be gitignored.

See `references/failure-mode-brief.md` for the brief's structure, the generic
seed lens menu to start from, and worked carving examples across domains.

---

## Phase 3 — Carve disjoint angles

Carve the brief into 4–7 **disjoint** angles whose union covers the failure
surface. Coverage must be **additive**: each Researcher owns a distinct slice,
overlap is minimal, nothing is left uncovered. Scale the count to the subsystem
— small handler → 3–4; full engine → 6–7. Beyond ~7 hits diminishing returns and
burns budget; below 4 tends to leave a bug class uncovered.

Pick whichever decomposition makes angles most disjoint for _this_ target (often
a combination):

- **By data-flow stage** — ingest → transform → persist → emit; one angle per stage.
- **By responsibility / module** — one angle per cohesive component.
- **By failure class** — assign each relevant lens from the brief as an angle.
- **By trust boundary** — each point where data or control crosses into the subsystem.

**Misleading implementations are a cross-cutting lens, not one angle.** Every
Researcher also flags code whose behavior diverges from its name, comments, or
apparent contract — silent caps, swallowed errors, no-op guards, stale comments,
reachable stubs. Put this in every prompt.

---

## Phase 4 — Dispatch the Researchers

Call the `task` tool once per angle with `subagent: Researcher`. **Issue the
calls together in one turn** so they run as independent parallel investigations.

The critical constraint: **a subagent runs in an isolated child session and sees
_only_ the prompt you give it.** It does not inherit this conversation, your map,
the brief, or the other Researchers' work. So every prompt must be **fully
self-contained** — point it at the brief scratch file (it can read it) and paste
the layout slice it needs.

Use this template per angle (fill the bracketed parts):

```
ROLE: You are a read-only Researcher. Investigate, gather ground truth, and
report. Do NOT edit, fix, or refactor any code.

TARGET: [subsystem name]

YOUR ANGLE: [angle name + one-sentence scope]. Stay in this lane; another
Researcher owns adjacent concerns.

WHERE TO LOOK: [paste the relevant slice of the Phase-1 inventory: files and
entry points for this angle]. Start there; follow call paths outward as needed.

WHAT TO HUNT: Read [path to the brief scratch file], section "[the section for
this angle]", and investigate each failure class there against the code.
Additionally flag MISLEADING IMPLEMENTATIONS: code whose behavior diverges from
its name, comments, or apparent contract; swallowed errors; silent caps; no-op
guards; stale comments; reachable TODO/stub paths.

EVIDENCE BAR: Report only findings you can ground in a concrete code path. For
each: file:line, the exact trigger/precondition, the resulting incorrect
behavior, severity. If you suspect a bug but cannot confirm the code path, label
it SUSPECTED and say what would confirm it. Do not assert bugs you can't point to.

OUTPUT: Return findings in the schema in [path to references/]bug-report-template.md
(the "Researcher report" section), grouped Confirmed Bug / Gap / Suspected /
Misleading-but-correct. State explicitly when a category is empty.
```

(If the Researcher can't read worktree files for some reason, inline that
angle's section of the brief into the prompt instead of pointing at the file.)

---

## Phase 5 — Consolidate & verify

When the Researchers return, you assemble the final report. This is where you
earn the word **"actual"** in "actual bugs and gaps."

1. **Collect** every finding from every Researcher.
2. **Deduplicate.** Overlapping angles surface the same bug from different
   directions — merge into one entry, keep the strongest evidence. Cross-angle
   corroboration _raises_ confidence; note it.
3. **Verify the evidence bar.** A **Confirmed Bug** must carry a concrete
   `file:line`, a concrete trigger/precondition, and a concretely wrong
   resulting behavior. Demote anything missing one to **Suspected — needs
   verification**.
4. **Confirm high-severity suspects.** For any high-severity SUSPECTED item,
   dispatch one more focused read-only Researcher (or `explore`) to confirm or
   kill it before asserting. Don't pad the final list with maybes.
5. **Separate bugs from gaps.** A _bug_ is wrong behavior in implemented code; a
   _gap_ is missing handling (no idempotency, unhandled case, reachable stub).
   Both go in the report, clearly distinguished.
6. **Produce the report** per `references/bug-report-template.md` (the "Final
   report" section): ordered by severity, each with location, trigger, impact,
   classification, confidence. Lead with a one-line tally so the reader can
   triage immediately.

Do not propose fixes unless the user asks — this skill produces the diagnosis.
Hand the verified list back; fixing is a separate step (and a separate agent).

---

## Guardrails

- **Read-only investigators.** No dispatched agent edits code. Neither do you in
  this skill.
- **Cheap by default.** Knowledge-first; web only when invariants must be exact;
  ask the user only when genuinely blocked. Don't add a research round-trip a
  domain you already know doesn't need.
- **No hallucinated bugs.** Unverifiable claims are SUSPECTED, never asserted as
  confirmed. The user wants _actual_ bugs.
- **Disjoint angles.** Overlap wastes budget; gaps in coverage lose bugs. Carve
  from the map and brief, not from memory.
- **Self-contained prompts.** Each subagent sees only its prompt + files it can
  read. Never assume it sees this conversation or another Researcher's output.
- **Diagnosis, not treatment.** Output is the bug/gap list. Stop there unless asked.
