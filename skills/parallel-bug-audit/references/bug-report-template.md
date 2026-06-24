# Bug report template

Reference for the `parallel-bug-audit` skill. Two schemas:

1. **Researcher report** — what each dispatched Researcher returns.
2. **Final report** — what the coordinator assembles and hands to the user.

The shared vocabulary keeps reports mergeable across angles.

## Severity

- **Critical** — silent data loss/corruption, or wrong data served to users.
- **High** — data loss/corruption only under a specific trigger, or a crash that
  blocks sync.
- **Medium** — recoverable incorrectness, drift that self-heals, or a gap that
  bites under load/edge conditions.
- **Low** — inefficiency, latent trap, or correctness issue with negligible
  blast radius.

## Classification

- **Confirmed bug** — wrong behavior in implemented code, grounded in a concrete
  code path.
- **Gap** — missing handling (no idempotency, no conflict resolution, unhandled
  case, reachable stub). The code isn't wrong; the case is absent.
- **Suspected** — plausible bug the investigator could not confirm against the
  code path. Carries what would confirm or kill it.
- **Misleading (not a bug)** — behavior diverges from name/comment/contract but
  is currently harmless. A latent trap; record it.

## Confidence

`Confirmed` (verified code path) · `Likely` (strong evidence, one inference) ·
`Suspected` (unconfirmed). Only `Confirmed` may be asserted as a bug in the
final report; everything else is labelled.

---

## 1. Researcher report (per angle)

Each Researcher returns this. Empty categories are stated explicitly ("No gaps
found for this angle.") so the coordinator can tell coverage from silence.

```
## Angle: [angle name]
## Files examined: [list of file:line ranges actually read]

### Confirmed bugs
- **[short title]** — `path/file.ts:LINE`
  - Trigger: [the exact precondition that makes it fire]
  - Behavior: [what actually happens — the wrong outcome]
  - Severity: [Critical|High|Medium|Low]
  - Evidence: [the specific code fact: the line, the missing check, etc.]

### Gaps
- **[short title]** — `path/file.ts:LINE` (or "absent: no handler for X")
  - Missing: [what handling is absent]
  - Consequence: [what happens when the uncovered case occurs]
  - Severity: [...]

### Suspected (needs verification)
- **[short title]** — `path/file.ts:LINE`
  - Why suspected: [the smell]
  - To confirm: [what to check / trace to confirm or kill]

### Misleading implementations
- **[short title]** — `path/file.ts:LINE`
  - Appears to: [what the name/comment/shape implies]
  - Actually: [what it does]
  - Active bug? [yes → also listed above | no → latent trap]
```

---

## 2. Final report (coordinator → user)

Lead with a tally so the reader can triage in one line, then the ordered list.

```
# Bug & gap audit — [target subsystem]

**Tally:** N confirmed bugs · M gaps · K suspected · J misleading (latent).
Angles covered: [A,B,C,...]. Files examined: [count or list].

## Confirmed bugs (by severity)

### 1. [title] — [Critical|High|Medium|Low]
- **Location:** `path/file.ts:LINE` [+ related sites]
- **Trigger:** [precondition]
- **Behavior:** [the wrong outcome]
- **Impact:** [blast radius — what/whom it affects]
- **Confidence:** Confirmed [note if corroborated across multiple angles]

### 2. ...

## Gaps

### G1. [title] — [severity]
- **Missing:** [absent handling]
- **Where it bites:** [the uncovered case + consequence]
- **Location:** `path/file.ts:LINE` (or "absent")

## Suspected — needs verification

### S1. [title] — [severity if real]
- **Smell:** [why it's suspicious]
- **To confirm:** [specific check/trace]
- *(High-severity suspects should have been confirmed or killed in Phase 4
  before this report — only genuinely ambiguous items remain here.)*

## Misleading implementations (latent traps)

### M1. [title]
- **Appears to / Actually:** [...]
- **Location:** `path/file.ts:LINE`

## Coverage notes
- [Anything an angle could not reach; any area deliberately out of scope; any
  conflicting findings between Researchers and how they were resolved.]
```

**Rules for the final report**

- Order confirmed bugs by severity, highest first.
- Every confirmed bug carries a real `file:line`. No location → it's Suspected.
- Bugs and gaps stay separate; don't blur "wrong" with "missing".
- No fixes unless the user asked — this report is the diagnosis.
- If two Researchers found the same issue, merge to one entry and note the
  cross-angle corroboration (it raises confidence).
