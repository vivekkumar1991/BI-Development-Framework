# Skill: subreports

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding/editing a `<Subreport>` item.

## Purpose

Embed a subreport and pass parameters correctly.

## Steps

1. Set `<Subreport>`'s `ReportName` to a report that exists in the project.
2. Map `<Parameters>`: each `<Parameter Name=...>` must match a `ReportParameter` in the
   **child** report; bind its `<Value>` to a field/expression/parameter in the **parent**.
3. Confirm the child's dataset/parameters can satisfy the passed values.
4. Watch rendering cost — subreports execute per parent row (see
   [`pagination-rendering`](pagination-rendering.md)).

## Output

A minimal subreport patch with valid parameter mapping. Check dependencies via
[`impact-analysis`](impact-analysis.md); structural checks via [`validation`](validation.md).
