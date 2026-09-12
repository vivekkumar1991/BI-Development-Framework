# Skill: sql-generation

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** operating mode is SQL_GENERATION (REFERENCE_LOGIC or query-local SQL output).

## Purpose

Assemble correct, **minimal** SQL from discovered schema + located logic.

## Rules

- Start from the confirmed objects/columns and the extracted logic; add only what was asked.
- Prefer set-based, sargable predicates; qualify all objects; parameterize inputs.
- Introduce joins/CTEs **only** when the requested result genuinely needs them; avoid
  duplicate-amplifying joins (verify grain).
- Preserve the reference logic's semantics exactly; **never invent** rules.
- Emit in the resolved dialect ([`sql-server`](sql-server.md) / [`databricks`](databricks.md)).
- Use only objects confirmed in the locked Active Data Source Context. Do not emit linked-server,
  cross-database/catalog, or cross-data-source references unless the user explicitly resolves
  and selects that single context for a new task.
- Preserve existing query parameters and explicitly requested filters. Generate or modify only
  **query-local SQL** from an explicit user requirement; never modify a database object, stored
  procedure, or RDL file.

## SP_TO_INLINE & REPORT_SCOPED_QUERY

Use when the SSRS handoff identifies a stored-procedure dataset, supplies the completed
`STORED_PROCEDURE_ANALYSIS` contract, and either:
1. The conversion class is `SAFE_CANDIDATE` (`LOW`/`MEDIUM` complexity) -> Generate `REPORT_LOCAL_SQL`.
2. The conversion class is `REVIEW_REQUIRED` (`HIGH` complexity) and `REPORT_SCOPED_QUERY` is selected -> Design a clean, minimal report-specific query containing only the tables, joins, filters, and fields actually required by the target report.

### Generation Rules:
- **Preserve Output Contract:** All existing output columns and aliases must be preserved.
- **Preserve Parameter Contract:** 1:1 parameter mappings (`@ParamName`) must match SSRS and procedure parameters.
- **Preserve Semantics:** Existing calculations, joins, `CASE` expressions, XML/STUFF aggregations, and JSON parsing paths are preserved verbatim.
- **Apply Requested Change:** Add only the requested report-specific logic (e.g. newly discovered/approved business field).
- **Hard Guardrail:** **NEVER modify the Stored Procedure**. The SQL Agent produces a new report-local query only and never alters shared database objects.

Do not infer missing source text, parameters, tables, columns, joins, filters, or business
logic. Unresolved business definitions stop for developer clarification. `DO_NOT_AUTO_CONVERT`
never produces inline SQL. The SQL Agent returns the approved SQL and provenance record only;
it never edits the RDL or the original procedure.

## Output

A minimal, correct query for [`query-validation`](query-validation.md), with a one-line note
on any reused logic, its source, and the Report-Local SQL Provenance Record.
