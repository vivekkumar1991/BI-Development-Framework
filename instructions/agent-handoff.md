# Agent Handoff Contract (SSRS → SQL)

Compact contract for when the [SSRS Agent](../agents/ssrs-agent.md) needs SQL work from the
[SQL Agent](../agents/sql-agent.md). Keep it minimal — send only relevant context, never
credentials or secrets (see [`security.md`](security.md)).

## Ownership

- **SSRS Agent owns** all RDL modifications. It does not duplicate SQL-agent reasoning.
- **SQL Agent owns** SQL generation and validation. It **never modifies RDL files**.

## Fields

```
Mode:                 BASIC_PULL | REFERENCE_LOGIC | SSRS_SUPPORT
Request:              <what is needed, one line>
Purpose:              <why — e.g. available-values for @CustomerId>
Target report/RDL:    <path under projectRoot, if applicable>
Source evidence:      <existing dataset/datasource facts observed in the RDL>
Engine:               <sqlserver | databricks>
Connection profile:   <logical profile name, e.g. local-sales-sql — NO physical host>
Database/catalog/schema: <as known from evidence/profile>
Required output:      <columns / result shape>
Value field:          <for parameter value binding, if applicable>
Label field:          <for parameter display, if applicable>
Reference logic:      <report/RDL to reuse business logic from, if applicable>
Constraints:          <read-only, ordering, DISTINCT, filters, limits>
```

## Rules

- Only relevant fields are sent; omit what does not apply.
- **No credentials or secrets** — pass the logical connection profile name only.
- SQL Agent returns: the query + validation/evidence (referenced objects, dialect, read-only).
- Read-only for data-pull work; write operations are never generated (see
  [`validation.md`](validation.md)).
- The SSRS Agent then wires the result into the RDL (value/label/available-values) using a
  minimal diff — and only adds report filtering when explicitly required.
