# Skill: report-reference-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** a report/RDL is the source of reference logic (REFERENCE_LOGIC).

## Purpose

Read a reference report to extract reusable logic accurately.

## Inspect

- **Dataset query** (`CommandText`) — the primary source of SQL logic.
- **Calculated fields** and `<Field>` expressions.
- **SSRS expressions** on items/filters/visibility that encode rules.
- **Filters, parameters, and the data source** the rule depends on.

## Rules

- Reuse only the **requested** logic; **do not copy unrelated complexity** from the report.
- Keep the reference's semantics; add only the extra columns/filters the user asked for.
- Confirm the reference's data source matches the resolved connection (or note the difference).

## Output

The relevant extracted logic + its dependencies, for
[`business-logic-discovery`](business-logic-discovery.md) / [`sql-generation`](sql-generation.md).
