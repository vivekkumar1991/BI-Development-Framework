# Skill: request-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** the first step of every SQL request.

## Purpose

Classify the request into one operating mode and decide which skills to load.

## Operating mode

Choose exactly one mode before any database access or SQL generation:

- **READ_ONLY** — retrieve data, inspect schema metadata, tables, views, stored procedures, or
	existing SQL. A read-only query may be executed only when approved read-only database access
	is available; otherwise return the query or inspection result without execution. Never emit or
	execute a write operation.
- **SQL_GENERATION** — generate a new query from an explicit requirement, or modify an existing
	**query-local** SQL statement when the user explicitly requests that change. Output SQL only;
	never modify a database object, stored procedure, or RDL file.

## Classify

- **BASIC_PULL** — READ_ONLY retrieval of named columns/filters, no business rules.
- **REFERENCE_LOGIC** — SQL_GENERATION request that references existing business logic
	("same X logic as report Y").
- **SSRS_SUPPORT** — READ_ONLY SSRS Agent handoff for parameter values, or SQL_GENERATION when
	the handoff explicitly requests a report-local query change.
- **STORED_PROCEDURE_ANALYSIS** — READ_ONLY analysis of a procedure referenced by an SSRS RDL
	or existing SQL workflow.
- **REFERENCE_LOGIC_DISCOVERY** — READ_ONLY progressive discovery of an unresolved business concept
	across the 7-level authoritative precedence hierarchy.
- **SP_TO_INLINE** — SQL_GENERATION request from the SSRS Agent to replace a stored-procedure
	dataset command with approved report-local inline SQL or REPORT_SCOPED_QUERY. It requires a completed
	`STORED_PROCEDURE_ANALYSIS` contract and proceeds only when the conversion class is
	`SAFE_CANDIDATE` or approved `REVIEW_REQUIRED`; `DO_NOT_AUTO_CONVERT` stops before any RDL change.

## Extract

- Required output (columns/result shape), filters, ordering, DISTINCT need.
- Source hints: RDL `DataSource` evidence for SSRS; otherwise an explicitly supplied logical
	data source, if present.
- Any optional named reference report/object for REFERENCE_LOGIC; a concept-only request may
	discover targeted same-context evidence through the active Catalog.

## Source selection

Pass source hints to [`connection-resolution`](connection-resolution.md) before loading source
evidence or generation skills. A standalone request with a named logical data source uses it.
Without one, proceed only when exactly one configured logical data source is unambiguous; ask
the user when the source is genuinely ambiguous. The returned Active Data Source Context is
locked for the task.

## Output

Chosen operating mode, request classification, and source hints feeding
[`connection-resolution`](connection-resolution.md) and the mode's generation skill. Keep
simple requests simple — do not escalate a BASIC_PULL into logic it didn't ask for.
