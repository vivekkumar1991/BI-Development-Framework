# Agent Handoff Contract (SSRS → SQL)

Compact contract for when the [SSRS Agent](../agents/ssrs-agent.md) needs SQL work from the
[SQL Agent](../agents/sql-agent.md). Keep it minimal — send only relevant context, never
credentials or secrets (see [`security.md`](security.md)).

## Ownership

- **SSRS Agent owns** all RDL modifications. It does not duplicate SQL-agent reasoning.
- **SQL Agent owns** SQL generation and validation. It **never modifies RDL files**.

## Fields

```
Mode:                 BASIC_PULL | REFERENCE_LOGIC | REFERENCE_LOGIC_DISCOVERY | SSRS_SUPPORT | STORED_PROCEDURE_ANALYSIS | SP_TO_INLINE
Request:              <what is needed, one line>
Purpose:              <why — e.g. available-values for @CustomerId>
Target report/RDL:    <path under projectRoot, if applicable>
Source evidence:      <existing dataset/datasource facts observed in the RDL>
Logical data source:  <logicalDataSources key>
Engine:               <sqlserver | databricks>
Connection profile:   <logical profile name, e.g. local-sales-sql>
Physical endpoint:    <developer-local profile endpoint; never a credential or secret>
Database/catalog/schema: <as known from the locked context>
Catalog binding:      <logical Catalog | endpoint | database | schema, if Catalog discovery is requested>
Required output:      <columns / result shape>
Value field:          <for parameter value binding, if applicable>
Label field:          <for parameter display, if applicable>
Reference logic:      <report/RDL to reuse business logic from, if applicable>
Stored Procedure:     <original schema.procedure, for STORED_PROCEDURE_ANALYSIS/SP_TO_INLINE>
Complexity risk tier: <LOW | MEDIUM | HIGH>
Execution mode:       <KEEP_SP | REPORT_LOCAL_SQL | REPORT_SCOPED_QUERY>
Conversion contract:  <SAFE_CANDIDATE | REVIEW_REQUIRED | DO_NOT_AUTO_CONVERT + analysis evidence>
Requested change:     <explicit report-specific SQL/business-logic change>
QueryParameters:      <existing names and SSRS expressions to preserve>
Constraints:          <read-only, ordering, DISTINCT, filters, limits>
```

## Rules

- Only relevant fields are sent; omit what does not apply.
- For any SSRS report-specific handoff, target resolution is a gate before SQL work: the
  SSRS Agent must first resolve the configured local `.sln`/`.rptproj` boundary and lock
  exactly one matching non-artifact RDL under its source root. `.rptproj` membership is
  preferred evidence but is not required when the source RDL physically exists under that
  root. A Catalog/deployed report is read-only evidence and cannot be used as the handoff's
  modification target or as a substitute for a missing local RDL. If the local RDL is
  missing, or more than one genuine source RDL matches, stop and return a clarification
  request; do not hand off for editing or SQL-to-RDL wiring.
- **No credentials or secrets** — the endpoint is developer-local metadata only; never pass a
  password, token, or connection string containing credentials.
- SSRS source evidence resolves and locks the Active Data Source Context before SQL work. A
  source from another endpoint, database/catalog, or logical data source is blocked and returned
  for user clarification; it is never combined automatically.
- Catalog discovery uses only the Catalog binding from the locked context. Pass only targeted
  Catalog evidence and reject records from another server, database/catalog, Catalog, or logical
  data source.
- SQL Agent returns: the query + validation/evidence (Active Data Source Context, referenced
  objects, dialect, read-only).
- For an approved `SP_TO_INLINE` handoff, the SQL Agent returns: original Stored Procedure
  reference, `SAFE_CANDIDATE` classification (or approved `REVIEW_REQUIRED`), selected execution
  mode (`REPORT_LOCAL_SQL` or `REPORT_SCOPED_QUERY`), generated report-local SQL, preserved
  `QueryParameters` mapping, requested change, validation result, provenance record, and
  confirmation that the original procedure was not modified. `REVIEW_REQUIRED` without explicit
  approval and `DO_NOT_AUTO_CONVERT` return a stop result with no inline SQL for RDL use.
- Read-only for data-pull work; write operations are never generated (see
  [`validation.md`](validation.md)).
- The SSRS Agent then wires the result into the RDL (value/label/available-values) using a
  minimal diff — and only adds report filtering when explicitly required.
