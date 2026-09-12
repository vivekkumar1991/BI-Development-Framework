# Skill: schema-discovery

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** objects/columns must be confirmed before writing SQL.

## Purpose

Ground READ_ONLY inspection and SQL_GENERATION in real objects/columns — never assume names.

## Sources (in order)

1. RDL dataset `<Query>`/`<Fields>` evidence from the handoff.
2. Provided existing SQL, schema/data dictionary, or sample DDL.
3. Read-only catalog lookups when a connection is available:
   - SQL Server: `INFORMATION_SCHEMA.COLUMNS` / `sys.columns`.
   - Databricks: `information_schema.columns` or `DESCRIBE TABLE`.
4. If still unknown, **ask** — do not invent columns.

## Stored procedure inspection

For a named procedure in the locked Active Data Source Context, inspect only the supplied
definition or targeted read-only metadata/definition evidence. Confirm its schema-qualified
name, input parameters and discoverable data types/defaults, and referenced objects. This is
targeted inspection, not catalog intelligence or broad catalog discovery. Never execute the
procedure, alter it, or infer source text that is unavailable.

## Context boundary

Use only evidence and read-only lookups in the locked Active Data Source Context from
[`connection-resolution`](connection-resolution.md). If a table, view, stored procedure, or
catalog belongs to another endpoint, database/catalog, or logical data source, block the
operation and ask the user to choose the context. Do not follow cross-server or cross-database
references automatically.

## Targeted Catalog discovery

Use Catalog evidence only after the active profile's Catalog configuration is bound to the locked
Active Data Source Context. Retrieve only records needed for the request; never load or search
the entire Catalog. Supported targeted evidence includes SSRS reports and report names/paths,
datasets, report parameters, stored-procedure references, available SQL/query definitions,
tables/views referenced by reports, and report-level business-logic evidence.

Use this precedence:

1. Current target report/RDL evidence, when the RDL is available.
2. Targeted evidence from the active-context Catalog.
3. Targeted reference-report evidence from other reports in that same context.
4. User clarification when evidence conflicts or is insufficient.

Catalog evidence supplements, never replaces, the current target RDL. Attach the logical data
source, engine, active endpoint/database/catalog, Catalog source/endpoint/database/schema, and
record identity to each result. Reject a result that cannot prove it belongs to the locked
context, rather than following it across servers, databases, catalogs, or logical data sources.

## Output

A confirmed list of qualified objects and columns (types where relevant) for
[`sql-generation`](sql-generation.md) / [`basic-query-generation`](basic-query-generation.md).
All lookups and inspection are **read-only**, targeted, and scoped to the Active Data Source
Context and its configured Catalog binding.
