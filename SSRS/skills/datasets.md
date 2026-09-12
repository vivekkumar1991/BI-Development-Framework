# Skill: datasets

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding/changing a dataset, its fields, or its query binding.

## Purpose

Manage embedded/shared datasets and their field lists while keeping queries safe.

## Steps

1. Identify whether the dataset is **embedded** or **shared**; note its `DataSource`.
2. For query changes, hand SQL work to the SQL Agent (SSRS Agent does not author complex SQL
   inline) via [`agent-handoff.md`](../../instructions/agent-handoff.md); wire the returned
   query into the `<CommandText>` and reconcile the `<Fields>` list.
3. Keep queries **parameterized**; map query parameters to report parameters.
4. Preserve existing field names used by report items (renaming a field ripples into
   expressions — check [`impact-analysis`](impact-analysis.md) first).

## Stored Procedure Datasets & Execution Modes

When a report request targets a dataset backed by a Stored Procedure (`<CommandType>StoredProcedure</CommandType>`), such as *"Add BuildDate to this report"*:

1. **Immutable Stored Procedure Rule:** Stored procedures are shared database dependencies and **must never be modified**. All report-specific changes are implemented at the report-local RDL layer.
2. **Three Execution Modes:**
   - **`KEEP_SP`:** Use the existing Stored Procedure when the requested change can be achieved without changing SQL logic (e.g. formatting, grouping, parameter prompts, report expressions).
   - **`REPORT_LOCAL_SQL`:** Convert the procedure into report-local inline SQL (`CommandType = Text`) when classified as `SAFE_CANDIDATE` (`LOW`/`MEDIUM` complexity) and performance/semantic risk is acceptable.
   - **`REPORT_SCOPED_QUERY`:** Instead of flattening an entire complex or `HIGH`-risk Stored Procedure (e.g. 12 temporary tables, indexing, multi-scan materialization), design a smaller report-specific query using only the tables, joins, filters, calculations, and columns actually required by the target report.
3. **Automated Delegation & Reference Logic Discovery:** Hand off to the SQL Agent with target report evidence, dataset name, data source reference, procedure name, existing `<QueryParameters>`, and requested change per [`agent-handoff.md`](../../instructions/agent-handoff.md). The SQL Agent automatically runs `REFERENCE_LOGIC_DISCOVERY` across the 7-level precedence hierarchy before requesting developer clarification for missing business definitions.
4. **Classification Handling:**
   - **`SAFE_CANDIDATE` / Approved `REPORT_SCOPED_QUERY`:** The SQL Agent returns approved report-local SQL with the new field, provenance record, and preserved parameter mappings. Apply the smallest dataset-only RDL patch:
     - Change `<CommandType>` to `Text` (or omit `<CommandType>` node, default is Text).
     - Replace `<CommandText>` with the approved inline SQL.
     - Add the new field to `<Fields>` with appropriate `<DataField>` and `<rd:TypeName>`.
     - Retain dataset name, `DataSourceName`, `<QueryParameters>`, and all report layout/expressions.
   - **`REVIEW_REQUIRED`:** Stop and present the review findings and candidate logic to the developer before any RDL modification.
   - **`DO_NOT_AUTO_CONVERT`:** Stop and report the blocker; do not modify RDL or procedure.
5. **No Business Logic Invention:** Similar column names are strictly non-authoritative. If the requested field cannot be derived from existing referenced tables or workspace reference logic, stop with a blocker. Never invent source columns or fake values.

## Backward Compatibility & Fast-Path Execution (Phase 11)

Simple SSRS dataset and layout tasks MUST remain lightweight and minimum-credit:
- **Simple Tasks:** Adding an existing dataset field to a tablix, removing an unused field, changing column width, updating headers, formatting dates/numbers, or toggling visibility.
- **Fast-Path Rule:** These simple tasks **MUST NOT** invoke Stored Procedure static analysis, `REFERENCE_LOGIC_DISCOVERY`, SQL Agent handoffs, `REPORT_SCOPED_QUERY`, or heavy database inspection unless the SQL query itself is explicitly being modified.

## Output

A minimal dataset patch with a consistent field list. Query dialect/validation is the SQL
Agent's responsibility; SSRS structural checks via [`validation`](validation.md).
