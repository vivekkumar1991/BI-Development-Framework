# Skill: report-reference-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** a report/RDL is the source of reference logic (REFERENCE_LOGIC).

## Purpose

Read a reference report to extract reusable logic accurately.

## Inspect

- **Dataset query** (`CommandText`) — the primary source of SQL logic.
- **CommandType** and schema-qualified procedure name when the dataset uses a stored procedure.
- **Calculated fields** and `<Field>` expressions.
- **SSRS expressions** on items/filters/visibility that encode rules.
- **Filters, parameters, and the data source** the rule depends on.

## Rules

- Reuse only the **requested** logic; **do not copy unrelated complexity** from the report.
- Keep the reference's semantics; add only the extra columns/filters the user asked for.
- Confirm the reference's data source matches the locked Active Data Source Context. If it
	belongs to another endpoint, database/catalog, or logical data source, block the operation
	and ask the user; do not automatically combine report sources.
- For a stored-procedure dataset, return its procedure name, the RDL query-parameter mappings,
  and the resolved Active Data Source Context to
  [`business-logic-discovery`](business-logic-discovery.md) for read-only analysis.
- After inspecting the current target RDL, use only targeted evidence from the Catalog binding in
	the locked Active Data Source Context when the requested concept needs more evidence. It may
	identify same-context report names/paths, datasets, parameters, queries, procedure references,
	referenced tables/views, and report-level logic. Search only the concept terms and necessary
	metadata; do not load the Catalog broadly or treat Catalog records as a replacement for an
	available RDL. Return the retrieved evidence and its context metadata for conflict evaluation,
	not automatic logic selection.

## Output

The relevant extracted logic + its dependencies, for
[`business-logic-discovery`](business-logic-discovery.md) / [`sql-generation`](sql-generation.md).
