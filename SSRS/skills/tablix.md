# Skill: tablix

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** editing tables, matrices, or lists (all are Tablix).

## Purpose

Modify Tablix rows, columns, groups, and cells with a minimal patch.

## Steps

1. Locate the `<Tablix>` and its `TablixBody` (columns/rows), `TablixColumnHierarchy`,
   `TablixRowHierarchy`, and any `TablixMember` groups.
2. For a **new column/row**: add the matching hierarchy member **and** the corresponding
   body cells so counts stay consistent — a mismatch corrupts the layout.
3. Bind cell contents via `expressions` (e.g. `=Fields!X.Value`); set headers explicitly.
4. Adjust group/sort/filter only as requested; keep existing group names/IDs.
5. Keep column widths/row heights coherent (see [`pagination-rendering`](pagination-rendering.md)).

## Output

A minimal Tablix patch with consistent row/column/cell counts. See
[`expressions`](expressions.md), [`formatting`](formatting.md), [`visibility`](visibility.md).
