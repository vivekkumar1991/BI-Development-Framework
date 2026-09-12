# Skill: validation

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** after an RDL edit or during pre-flight inspection, before handing to the Validation Agent.

## Purpose

Run **focused, deterministic, schema-aware pre-flight structural RDL checks** so that
SSRS/SSDT report definition errors are detected **before** the modified RDL is opened,
previewed, deployed, or executed. (Visual/render verification remains a developer/SSDT step.)

## Pre-flight validation gate

Every RDL change must produce an explicit pre-flight status:

```text
PREFLIGHT_STATUS = PASS | FAIL | CLARIFICATION_REQUIRED
```

- **`PASS`** — all structural, schema, parameter, dataset, and reference checks succeed. Safe to hand to the Validation Agent and proceed to developer preview.
- **`FAIL`** — one or more deterministic structural errors detected (e.g. parameter count vs parameter panel cell definition mismatch). Preview, execution, and deployment are **strictly blocked**.
- **`CLARIFICATION_REQUIRED`** — ambiguity detected (e.g. conflicting parameter bindings, ambiguous schema intent, or multiple inconsistent layouts) that cannot be safely auto-fixed without risking business logic. Stop and ask the developer.

## Five distinct failure domains

Always separate failures into the correct domain. Never report a database connection or query failure when the RDL itself is structurally invalid:

| Domain | Category | Description | Ownership |
|--------|----------|-------------|-----------|
| **A** | **RDL Structural / Pre-Flight** | XML malformed, schema invalid, parameter panel cell mismatch, orphaned/missing parameter refs, bad field mappings, duplicate names. | SSRS Agent / Pre-Flight Validation |
| **B** | **SQL / Query Validation** | SQL syntax errors, invalid table/column references in query, unsafe write statements, unsargable predicates. | SQL Agent (`query-validation`) |
| **C** | **Database Connectivity** | Network unreachable, authentication failure, server timeout, missing credentials. | Environment / Runtime only |
| **D** | **Database Execution / Runtime** | Execution runtime errors (e.g. division by zero in query, data type conversion error during query execution). | Database Runtime |
| **E** | **SSRS Designer / Rendering** | Physical page overflow, printer margin clipping, interactive drilldown rendering. | Developer / SSDT step |

---

## Validation areas & checks

### 1. Report Parameters
- [ ] Count of defined `<ReportParameter>` elements matches expected design.
- [ ] Parameter names are unique, non-empty, and valid PascalCase identifiers.
- [ ] Data types are valid SSRS types: `String`, `Boolean`, `DateTime`, `Integer`, `Float`.
- [ ] Default values (`<DefaultValue>`) point to valid static values or resolving dataset queries.
- [ ] Available values (`<AvailableValues>`) reference a valid dataset with valid `ValueField` and `LabelField`.
- [ ] Parameter dependencies: cascading parameters only reference preceding parameters; no circular dependencies.
- [ ] Detect and reject orphaned, duplicated, or unreferenced parameter definitions.

### 2. Parameter Panel / Layout (Schema-Aware)
- [ ] **Detect RDL schema version** from `<Report xmlns="...">`:
  - **2016/01 schema** (`http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition`):
    - When `<ReportParametersLayout>` is present, validate that:
      - `count(ReportParameters/ReportParameter) == count(ReportParametersLayout/GridLayoutDefinition/CellDefinitions/CellDefinition)`
      - Every `<CellDefinition>/<ParameterName>` corresponds to an existing, defined `<ReportParameter Name="...">`.
      - Every defined `<ReportParameter>` has exactly one corresponding `<CellDefinition>`.
      - `<ColumnIndex>` and `<RowIndex>` are non-negative, unique across cells, and fit within `<NumberOfColumns>` and `<NumberOfRows>`.
      - If `<ReportParameters>` is empty, `<ReportParametersLayout>` must contain no cell definitions or be omitted.
  - **2010/01 schema** (`http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition`) and earlier (`2008/01`, `2005/01`):
    - `<ReportParametersLayout>` is **not supported** by the schema.
    - Reject any `<ReportParametersLayout>` in 2010/01 or older RDLs as schema-incompatible.
    - Do not require or add parameter panel layout metadata for older schemas.
  - **Guardrail:** Never upgrade an RDL schema version merely to make layout validation pass.

### 3. Parameter References
- [ ] Dataset query parameters (`<QueryParameters>/<QueryParameter>/<Value>`) referencing `=Parameters!ParamName.Value` must match an actual defined `<ReportParameter Name="ParamName">`.
- [ ] Report expressions referencing `=Parameters!ParamName.Value` or `=Parameters!ParamName.Label` across textboxes, tablix cells, grouping, sorting, calculated fields, and visibility expressions resolve to valid parameters.
- [ ] Filter expressions and actions (drillthrough parameter passing, bookmark, jump-to-report) referencing parameters resolve.
- [ ] Detect references to nonexistent parameters (`UNDEFINED_PARAMETER_REF`).
- [ ] Detect defined parameters that have invalid, broken, or inconsistent bindings.

### 4. Dataset / Query Consistency
- [ ] Dataset query parameters correspond to report parameters where applicable.
- [ ] Dataset fields (`<Fields>/<Field Name="...">`) are structurally sound:
  - Non-calculated fields have `<DataField>FieldSource</DataField>`.
  - Calculated fields have `<Value>=Expression</Value>`.
  - Newly added fields contain valid `<rd:TypeName>` metadata if present in surrounding fields.
- [ ] Statically determinable query/field inconsistencies detected without requiring database execution.
- [ ] Report items (Tablix, List, Matrix, Chart) with `<DataSetName>` reference an existing `<DataSet Name="...">`.

### 5. RDL Structural Consistency & Change Scope Guard
- [ ] `.rdl` is **valid XML**; XML declaration and root `<Report>` well-formed.
- [ ] RDL **namespace is preserved** and matches the original file.
- [ ] Required parent/child node hierarchies are valid per schema.
- [ ] Names and IDs are unique within their scope (no duplicate dataset names, parameter names, report item names, group names).
- [ ] Tablix row/column/cell counts are consistent; grid dimensions match cell definitions.
- [ ] Subreport references and image references are well-formed.
- [ ] **Change Scope / Diff Guard (Phase 8):** Verify that changes are strictly restricted to the target scope (target dataset query, required fields, explicit requested additions). Any unexpected broad diffs affecting unrelated datasets, parameters, page dimensions, margins, or unrelated formatting are strictly rejected with `REVIEW_REQUIRED` (see [`rdl-minimal-editing`](rdl-minimal-editing.md)).
- [ ] **SP_TO_INLINE / REPORT_SCOPED_QUERY:**
  - Only the target dataset query and required fields changed.
  - Dataset name and `DataSourceName` are preserved.
  - 1:1 parameter mappings and all existing output columns, filters, joins, calculations, and aggregations are strictly preserved.
  - Report-Local SQL Provenance Record verified.
  - Shared Stored Procedure is 100% untouched.

---

## Cost optimization & risk-based triggering

To optimize token and execution cost, pre-flight validation is risk-based:

| Change Category | Triggered Validation Level |
|-----------------|----------------------------|
| **Formatting-only** (font, color, padding, borders) | **Low risk:** XML well-formedness + minimal diff verification. Full parameter/dataset analysis omitted. |
| **Visibility / toggles** | **Medium risk:** XML well-formedness + expression reference validation + minimal diff. |
| **Parameters / Parameter Panel** | **High risk (Full Pre-Flight):** Parameter count, parameter panel layout reconciliation, expression references, query parameter bindings. |
| **Datasets / Fields / Query** | **High risk (Full Pre-Flight):** Dataset consistency, field definitions, query parameter mapping, report item dataset references. |
| **Tablix / Grouping / Structure** | **High risk (Full Pre-Flight):** Structural consistency, cell/column counts, group expressions, dataset references. |
| **SP_TO_INLINE / SQL change** | **High risk (Full Pre-Flight):** Dataset query, query parameter mappings, field consistency, SQL Agent handoff contract verification. |

---

## Safe auto-fix protocol

When a deterministic structural defect is identified during pre-flight validation:

1. **Eligible for Auto-Fix:**
   - **Parameter Panel synchronization (2016/01 schema):** Reconcile `<ReportParametersLayout>` by adding, removing, or updating `<CellDefinition>` entries to match `<ReportParameters>` exactly, recalculating `<NumberOfColumns>` and `<NumberOfRows>` appropriately.
   - **Parameter name mismatch in layout:** Update `<CellDefinition>/<ParameterName>` to match a renamed `<ReportParameter>`.
   - **Orphaned layout cells:** Remove cell definitions referencing deleted parameters.
2. **Auto-Fix Constraints:**
   - Preserve all existing parameter definitions, data types, prompts, defaults, available values, and query bindings.
   - Preserve all existing datasets, fields, expressions, tablix layouts, and business logic.
   - Never upgrade the RDL schema version.
   - Never modify SQL or Stored Procedures to fix an RDL structural issue.
3. **Ineligible (STOP and return `CLARIFICATION_REQUIRED`):**
   - Ambiguous parameter ordering or multiple contradictory layout configurations.
   - Schema version conflict (e.g. older schema requesting 2016 layout features).
   - Missing dataset fields or query parameter bindings where business intent is unclear.

---

## Error presentation standard

When pre-flight validation fails or requires clarification, format the response as follows:

```text
SSRS PREFLIGHT VALIDATION FAILED

Severity: BLOCKING
Category: <Parameter Panel | Report Parameters | Parameter References | Dataset / Query Consistency | RDL Structural>
Issue:
<Exact description of the failure, e.g. Report defines 2 parameters, but the parameter panel contains an incompatible number of cell definitions.>

Action:
Report preview/deployment was blocked.

Suggested fix:
<Concrete, minimal fix steps, e.g. Reconcile parameter-panel metadata with the defined parameters without changing unrelated report configuration.>
```

## Output

A pre-flight validation receipt feeding the [Validation Agent](../../agents/validation-agent.md).
Canonical checklist: [`instructions/validation.md`](../../instructions/validation.md).
