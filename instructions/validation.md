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

- [ ] **Target resolution is locked before RDL analysis, editing, or SSRS-to-SQL handoff:**
  exactly one matching non-artifact RDL exists under the configured local `.sln`/`.rptproj`
  source root and is the only modification target. `.rptproj` membership is preferred
  evidence but is not required when the source RDL physically exists under that root. A
  Catalog/deployed report is read-only evidence only; it cannot replace the local RDL.
  Missing local matches and ambiguous local matches stop for user clarification.
  *(BLOCKER if violated)*
- [ ] Build/output/generated copies under `bin`, `obj`, `Debug`, `Release`, `build`, `out`,
  `publish`, or equivalent artifact directories are ignored and never compete with a
  source RDL. `*.spec.md` and other documentation files are ignored as modification
  targets. *(BLOCKER if violated)*
- [ ] No real RDL, Catalog object, Stored Procedure, database object, or production system
  was modified while resolving or validating the target. *(BLOCKER if violated)*
- [ ] Datasets are **parameterized**; no string-concatenated SQL. *(BLOCKER if violated)*
- [ ] Parameters have sensible defaults and validation.
- [ ] No embedded credentials in the `.rdl`. *(BLOCKER if violated)*
- [ ] Layout renders sensibly; expressions kept simple.
- [ ] Report spec/parameters documented.

**SSRS Pre-Flight Structural Validation Gate (before preview, deployment, or execution):**

- [ ] **Pre-Flight Gate Evaluated:** Report evaluation produces an explicit status:
  `PREFLIGHT_STATUS = PASS | FAIL | CLARIFICATION_REQUIRED`. Deterministic failures block preview and deployment immediately. *(BLOCKER if FAIL)*
- [ ] **Separation of Failure Domains:** Issues are classified into their proper domain:
  - **A. RDL Structural / Pre-Flight** (schema mismatch, parameter panel cell count mismatch, broken parameter refs, invalid XML).
  - **B. SQL / Query Validation** (SQL syntax, ambiguous columns, un-sargable joins).
  - **C. Database Connectivity** (network unreachable, auth/timeout).
  - **D. Database Execution / Runtime** (query execution errors, division by zero).
  - **E. SSRS Designer / Rendering** (visual pagination overflow, printer limits).
  *Rule: Never report a database connectivity failure when the RDL itself is structurally invalid.*
- [ ] **Parameter Panel & Layout Compatibility (Schema-Aware):**
  - **2016/01 schema:** When `<ReportParametersLayout>` is present, `count(ReportParameters/ReportParameter)` must **strictly equal** `count(CellDefinitions/CellDefinition)`. Each cell must bind to a defined parameter name, and grid coordinates must be unique and within bounds. *(BLOCKER if mismatched)*
  - **2010/01 and older schemas:** `<ReportParametersLayout>` must **not** be present. Never require layout elements or upgrade schema for older RDLs. *(BLOCKER if present in older schema)*
- [ ] **Parameter References:** All parameter references (`=Parameters!Name.Value` or `.Label`) in dataset query parameters, textboxes, tablix cells, grouping, sorting, calculated fields, visibility, and drillthrough actions resolve to existing defined `<ReportParameter>` elements. *(BLOCKER if unresolvable)*
- [ ] **Dataset / Query Consistency:** Dataset query parameters map to defined report parameters. Dataset `<Fields>` are structurally valid (`<DataField>` or `<Value>`), and report item `<DataSetName>` references resolve to existing datasets. *(BLOCKER if inconsistent)*
- [ ] **RDL Structural Integrity:** Valid XML; namespace preserved; required parent/child relationships intact; unique names/IDs within scopes; tablix dimensions consistent. *(BLOCKER if invalid)*
- [ ] **Unexpected broad diff is rejected** — the change is a targeted patch, unrelated XML
      is untouched (see [`SSRS/skills/rdl-minimal-editing.md`](../SSRS/skills/rdl-minimal-editing.md)). *(BLOCKER if broad diff)*
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
- [ ] **Stored Procedures are immutable shared dependencies:** Never contain `ALTER`, `CREATE OR ALTER`, `CREATE`, or `DROP` statements targeting stored procedures or shared database objects. *(BLOCKER if violated)*
- [ ] **Stored Procedure Analysis & Complexity Tiers:** `SP_ANALYSIS_STATUS` is explicitly evaluated (`SAFE_CANDIDATE`, `REVIEW_REQUIRED`, `DO_NOT_AUTO_CONVERT`) along with Complexity Tier (`LOW`, `MEDIUM`, `HIGH`) and execution mode (`KEEP_SP`, `REPORT_LOCAL_SQL`, `REPORT_SCOPED_QUERY`). High-complexity temp-table pipelines are not blindly flattened. *(BLOCKER if violated)*
- [ ] **Reference Logic Discovery & No Invention:** Unresolved business concepts follow the 7-level discovery precedence before developer inquiry. Similar column names are strictly non-authoritative. No unverified business logic or unresolvable objects were invented. *(BLOCKER if violated)*
- [ ] **Report-Local SQL Provenance & Contract Preservation:** Report-local SQL/REPORT_SCOPED_QUERY carries a complete provenance record; 1:1 parameter mappings and all existing output columns, filters, joins, calculations, and aggregations are strictly preserved; only explicitly requested report-specific logic was added. *(BLOCKER if violated)*

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
