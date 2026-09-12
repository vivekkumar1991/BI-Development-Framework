# Skill: connection-resolution

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** any request needs a database target.

## Purpose

Resolve the connection **without guessing servers or databases**.

## Active Data Source Context

Resolve exactly one context before inspecting sources or generating SQL. The context is
**locked for the current task** and contains:

```
Logical data source : <logicalDataSources key>
Engine              : <sqlserver | databricks>
Physical endpoint   : <developer-local connectionProfiles.endpoint>
Database/catalog    : <connectionProfiles.database>
Schema              : <connectionProfiles.schema, when configured>
Catalog source       : <connectionProfiles.catalog.logicalCatalog, when configured>
Catalog endpoint     : <connectionProfiles.catalog.endpoint, when configured>
Catalog database     : <connectionProfiles.catalog.database, when configured>
Catalog schema       : <connectionProfiles.catalog.schema, when configured>
```

The endpoint is developer-local configuration metadata, never a credential or secret, and is
never committed. Once locked, do not change or add a source context implicitly. If an object,
report reference, or business-logic source resolves to another endpoint, database/catalog, or
logical data source, stop and ask the user to select a single context; never combine sources.

## Context lock protocol

The Active Data Source Context is the task's single source-admission boundary. Keep the same
logical data source, engine, physical endpoint, database/catalog, and schema for the entire
task; the configured Catalog binding is also fixed when Catalog discovery is used. Before using
a table, view, stored procedure, report/RDL, Catalog record, SQL definition, or business-logic
evidence, compare its known source metadata with the lock. Admit it only when all known values
match. Missing or conflicting source metadata is a conflict, not permission to infer a match.

On a conflict, stop the current operation and request clarification. Do not switch the active
context, issue a cross-server/cross-database reference, search another Catalog, or combine
evidence from more than one context in the same task.

## Catalog resolution

Catalog discovery is optional until requested. When it is requested, bind exactly one Catalog
configuration from the resolved connection profile's `catalog` object to the locked Active Data
Source Context. Never infer, borrow, or search another profile's Catalog. If the active profile
has no Catalog configuration, has conflicting mappings, or cannot prove its Catalog source,
ask the user for clarification; do not guess.

The Catalog endpoint, database, and schema are developer-local metadata and must remain in the
gitignored local configuration. They are not credentials and must never include passwords,
tokens, or credential-bearing connection strings.

## Priority

1. **Existing RDL data-source evidence** — engine, database/catalog, schema from the report.
2. **Developer-local logical profile** in `SSRS/workspace.config.json`
   (`logicalDataSources` → `connectionProfiles`).
3. **User clarification** — ask for the minimum non-secret info.

For an SSRS request, use matching RDL `DataSource` evidence first, then complete the context
from its mapped local profile. For a standalone SQL request, use an explicitly supplied
logical data source. Otherwise, use the configured source only when exactly one logical data
source can satisfy the request; ask the user only when more than one source is plausible or no
configured source can be resolved.

## Three-layer model

```
Logical Data Source  ->  Connection Profile  ->  Physical Environment
   SalesDB                 local-sales-sql        this developer's SQL Server / VDI
```

Each logical name maps to one local profile; profiles may target different SQL Server, VM, or
VDI environments. The same logical name may map to each developer's own physical endpoint, so
the repo stays environment-independent. **Physical endpoints live only in developer-local
config.**

## Output

The locked **Active Data Source Context** for generation: logical data source, engine,
physical endpoint, database/catalog, schema, and its configured Catalog binding when requested.
No credentials — prefer approved auth; never request secrets in chat
(see [`security.md`](../../instructions/security.md)). Engine specifics:
[`sql-server`](sql-server.md) / [`databricks`](databricks.md).
