# Skill: parameters

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding, modifying, or removing a report parameter.

## Purpose

Create/modify `ReportParameter`s correctly, distinguish input styles, and keep parameter panel
layout metadata in lockstep with defined parameters according to the detected RDL schema.

## Decide the style

- **Free-form input** — user types a value. Create only the required `ReportParameter`
  (data type, prompt, default/nullable/multi-value as requested). Nothing else.
- **Selectable (from a list)** — values come from a set:
  1. Inspect existing datasets first; reuse one if it can safely supply the values.
  2. If none fits, hand off to the SQL Agent in **SSRS_SUPPORT** mode via
     [`agent-handoff.md`](../../instructions/agent-handoff.md) (value field, label field,
     source evidence, engine, profile — **no secrets**).

## Wiring

After the query is available, set `AvailableValues` (value + label), defaults, and prompt.
Bind report **filtering/query** to the parameter **only when explicitly requested** — creating
a parameter does not imply filtering. If ambiguous, **ask first**.

## Parameter Panel & Layout Synchronization (Schema-Aware)

When creating, updating, renaming, or deleting report parameters, ensure layout metadata
remains consistent with the report's schema version:

### 2016/01 Schema (`.../2016/01/reportdefinition`)
- When the RDL defines `<ReportParameters>`, it must maintain a synchronized
  `<ReportParametersLayout>` with matching `<CellDefinitions>`:
  - **Count Match:** The number of `<CellDefinition>` entries must **exactly equal** the
    number of defined `<ReportParameter>` elements.
  - **Name Match:** Each `<CellDefinition>/<ParameterName>` must reference an existing
    `<ReportParameter Name="...">`.
  - **Grid Alignment:** `<ColumnIndex>` (0-based) and `<RowIndex>` (0-based) must be unique
    and fit within `<NumberOfColumns>` and `<NumberOfRows>`.
  - **On Add:** Add a new `<CellDefinition>` for the new parameter, assigning next available
    `<ColumnIndex>`/`<RowIndex>` coordinates and updating `<NumberOfRows>`/`<NumberOfColumns>`
    if needed.
  - **On Remove:** Remove the corresponding `<CellDefinition>` and compact grid coordinates.
  - **On Rename:** Update `<ParameterName>` in the matching `<CellDefinition>`.

```xml
<ReportParametersLayout>
  <GridLayoutDefinition>
    <NumberOfColumns>4</NumberOfColumns>
    <NumberOfRows>1</NumberOfRows>
    <CellDefinitions>
      <CellDefinition>
        <ColumnIndex>0</ColumnIndex>
        <RowIndex>0</RowIndex>
        <ParameterName>StartDate</ParameterName>
      </CellDefinition>
    </CellDefinitions>
  </GridLayoutDefinition>
</ReportParametersLayout>
```

### 2010/01 and Older Schemas (`.../2010/01/...`, `.../2008/01/...`, `.../2005/01/...`)
- Older schemas do **not** support `<ReportParametersLayout>`.
- **Never** add `<ReportParametersLayout>` to a 2010/01 or older RDL.
- **Never** upgrade an RDL schema version merely to add parameter layout metadata.

## Safe Auto-Fix for Parameter Panel Defects

If pre-flight validation detects a mismatch between defined parameters and `<ReportParametersLayout>`
on a 2016/01 RDL:
1. Deterministically reconcile the cell definitions:
   - For missing cell definitions: insert `<CellDefinition>` nodes at next free grid slot.
   - For orphaned cell definitions: remove `<CellDefinition>` nodes referencing deleted parameters.
   - Update `<NumberOfColumns>` and `<NumberOfRows>` to match grid dimensions.
2. Preserve all existing parameter definitions, defaults, dataset bindings, expressions, and layout.
3. If parameter order or placement is ambiguous: STOP and report `PREFLIGHT_STATUS = CLARIFICATION_REQUIRED`.

## Output

A minimal parameter patch with synchronized parameter panel metadata (if applicable).
Validate with [`validation`](validation.md); see also [`datasets`](datasets.md),
[`ssrs-parameter-query`](../../SQL/skills/ssrs-parameter-query.md).
