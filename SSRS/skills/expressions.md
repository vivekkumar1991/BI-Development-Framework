# Skill: expressions

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** editing SSRS/VB expressions, aggregates, or field references.

## Purpose

Write/adjust `=`-expressions correctly while keeping them simple.

## Guidance

- Reference fields as `=Fields!Name.Value`; aggregates as `=Sum(Fields!X.Value)` within the
  correct scope (dataset/group name as second arg when needed).
- Use `ReportItems!Textbox.Value` only for layout-derived values; prefer dataset fields.
- Handle nulls (`IIf(IsNothing(...))`) and division-by-zero explicitly.
- Keep expressions readable; push heavy business logic to SQL (see the SQL Agent), don't
  reinvent it in the report.
- When translating an expression's meaning **into SQL**, that is the SQL Agent's
  `REFERENCE_LOGIC` job — preserve semantics exactly; **never invent logic**.

## Output

Minimal expression edits bound to existing fields/scopes. Validate references with
[`validation`](validation.md).
