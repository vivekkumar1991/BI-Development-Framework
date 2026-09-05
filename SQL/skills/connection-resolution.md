# Skill: connection-resolution

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** any request needs a database target.

## Purpose

Resolve the connection **without guessing servers or databases**.

## Priority

1. **Existing RDL data-source evidence** — engine, database/catalog, schema from the report.
2. **Developer-local logical profile** in `SSRS/workspace.config.json`
   (`logicalDataSources` → `connectionProfiles`).
3. **User clarification** — ask for the minimum non-secret info.

## Three-layer model

```
Logical Data Source  ->  Connection Profile  ->  Physical Environment
   SalesDB                 local-sales-sql        this developer's SQL Server / VDI
```

Same logical name → each developer's own physical endpoint, so the repo stays
environment-independent. **Physical endpoints live only in developer-local config.**

## Output

Resolved metadata for generation: **engine, logical profile, database, catalog/schema**.
No physical host, **no credentials** — prefer approved auth; never request secrets in chat
(see [`security.md`](../../instructions/security.md)). Engine specifics:
[`sql-server`](sql-server.md) / [`databricks`](databricks.md).
