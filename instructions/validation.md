# Validation

The checklist the [Validation Agent](../agents/validation-agent.md) runs after specialist
work. Specialists also self-check against the relevant items before handoff.

## Severity levels

- **BLOCKER** — must be fixed before the work is done.
- **WARNING** — should be fixed; the user may accept with justification.
- **NOTE** — informational / improvement suggestion.

## Common checklist (all technologies)

- [ ] Meets [development standards](development-standards.md) (naming, structure, style).
- [ ] Complies with [security](security.md): no secrets, no prod connection, parameterized,
      no PII. *(violations = BLOCKER)*
- [ ] [Documentation](documentation.md) complete: headers, purpose, parameters, change note.
- [ ] Scope matches the objective; nothing unrequested was changed.
- [ ] `README.md` untouched.
- [ ] No business report was created unless explicitly requested.
- [ ] No commit/push/deploy performed unless the user asked.
- [ ] Result is reproducible from what's in the repo (no undocumented manual steps).

## Power BI checklist

- [ ] Measures follow naming standards and each has a documented intent.
- [ ] DAX uses `VAR` for readability; no unnecessary recomputation.
- [ ] No hardcoded filters where a parameter/slicer belongs.
- [ ] Power Query steps are named and folding-friendly where possible.
- [ ] RLS considered when data is sensitive.
- [ ] Model/measure documentation updated.

## SSRS checklist

- [ ] Datasets are **parameterized**; no string-concatenated SQL. *(BLOCKER if violated)*
- [ ] Parameters have sensible defaults and validation.
- [ ] No embedded credentials in the `.rdl`. *(BLOCKER if violated)*
- [ ] Layout renders sensibly; expressions kept simple.
- [ ] Report spec/parameters documented.

**Structural RDL validation (AI, after a minimal edit):**

- [ ] `.rdl` is **valid XML** and the RDL **namespace is preserved**.
- [ ] Expected nodes exist for the change (parameter / dataset / tablix / report item).
- [ ] Parameter, dataset, and data-source references resolve.
- [ ] Field references resolve where statically checkable.
- [ ] Group / filter / action (drillthrough, navigation) references remain coherent.
- [ ] Report item dimensions/positions are valid.
- [ ] **Unexpected broad diff is rejected** — the change is a targeted patch, unrelated XML
      is untouched (see [`SSRS/skills/rdl-minimal-editing.md`](../SSRS/skills/rdl-minimal-editing.md)).
- [ ] Visual/render verification is a developer/SSDT step (out of AI scope).

## SQL checklist

- [ ] **Parameterized**; no injection risk. *(BLOCKER if violated)*
- [ ] Correct **dialect** for the resolved engine (SQL Server / Databricks).
- [ ] Referenced objects/columns exist per discovered schema/source evidence.
- [ ] Parameter placeholders correct; no ambiguous (unqualified) columns.
- [ ] No unintended Cartesian joins or duplicate-amplifying joins.
- [ ] Filter correctness and null behavior are sound.
- [ ] Set-based rather than row-by-row (unless justified).
- [ ] Sargable predicates; indexing/plan implications noted.
- [ ] Error handling (`TRY...CATCH`) and transactions for multi-statement writes.
- [ ] Object references schema-qualified.

**Read-only safety (data-pull / BASIC_PULL / SSRS_SUPPORT):**

- [ ] Query is **read-only**. Never `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `DROP`, `ALTER`,
      or `TRUNCATE` (or any other write) in data-pull work. *(BLOCKER if violated)*
- [ ] No destructive statements outside an approved non-prod context. *(BLOCKER if violated)*

## Output

The Validation Agent returns a report:

```
Result   : PASS | PASS WITH NOTES | FAIL
Summary  : <one line>
Findings :
  - [BLOCKER] ...
  - [WARNING] ...
  - [NOTE]    ...
```

A result of **FAIL** (any BLOCKER) returns to the specialist via the Router for correction.
