# Skill: schema-discovery

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** objects/columns must be confirmed before writing SQL.

## Purpose

Ground the query in real objects/columns — never assume names.

## Sources (in order)

1. RDL dataset `<Query>`/`<Fields>` evidence from the handoff.
2. Provided schema/data dictionary or sample DDL.
3. Read-only catalog lookups when a connection is available:
   - SQL Server: `INFORMATION_SCHEMA.COLUMNS` / `sys.columns`.
   - Databricks: `information_schema.columns` or `DESCRIBE TABLE`.
4. If still unknown, **ask** — do not invent columns.

## Output

A confirmed list of qualified objects and columns (types where relevant) for
[`sql-generation`](sql-generation.md) / [`basic-query-generation`](basic-query-generation.md).
All lookups are **read-only**.
