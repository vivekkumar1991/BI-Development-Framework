# Skill: visibility

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** showing/hiding items or adding toggles.

## Purpose

Control `Visibility` on report items, rows, columns, and groups minimally.

## Steps

1. Set `<Visibility><Hidden>` (static `true`/`false`) or an expression for conditional show/hide.
2. For interactive toggles, set `ToggleItem` to the name of an existing textbox; ensure that
   textbox exists and is in a valid scope.
3. For group-level visibility, edit the correct `TablixMember`'s `Visibility`.
4. Do not alter unrelated items' visibility; keep names/IDs stable.

## Output

A minimal visibility patch. Confirm toggle targets resolve via
[`validation`](validation.md) and [`impact-analysis`](impact-analysis.md).
