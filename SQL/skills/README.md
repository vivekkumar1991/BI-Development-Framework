# SQL Skills

Modular, domain-specific skills for the [SQL Agent](../../agents/sql-agent.md). Each skill is
**behavior only** — general security, Git, documentation, and validation *policy* lives in the
canonical [`instructions/`](../../instructions/) and is referenced, not restated.

**Load only the skills a request needs** (token efficiency). Typical bundles:

| Mode / request | Skills |
|----------------|--------|
| BASIC_PULL | `request-analysis`, `connection-resolution`, `schema-discovery`, `basic-query-generation`, `query-validation` |
| REFERENCE_LOGIC / REFERENCE_LOGIC_DISCOVERY | `request-analysis`, `connection-resolution`, `report-reference-analysis`, `business-logic-discovery`, `sql-generation`, `query-validation` |
| SSRS_SUPPORT | `request-analysis`, `connection-resolution`, `ssrs-parameter-query`, `query-validation` |
| STORED_PROCEDURE_ANALYSIS | `request-analysis`, `connection-resolution`, `stored-procedure-analysis`, `schema-discovery`, `query-validation` |
| SP_TO_INLINE / REPORT_SCOPED_QUERY | `request-analysis`, `connection-resolution`, `stored-procedure-analysis`, `business-logic-discovery`, `sql-generation`, `query-validation` |
| Engine-specific | `+ sql-server` or `+ databricks` |
| Change impact | `+ impact-analysis` |

## Catalog

| Skill | Purpose |
|-------|---------|
| [`request-analysis`](request-analysis.md) | Classify into BASIC_PULL / REFERENCE_LOGIC / SSRS_SUPPORT / STORED_PROCEDURE_ANALYSIS / REFERENCE_LOGIC_DISCOVERY / SP_TO_INLINE. |
| [`connection-resolution`](connection-resolution.md) | Resolve engine/profile/database without guessing. |
| [`stored-procedure-analysis`](stored-procedure-analysis.md) | Static read-only stored procedure analysis, complexity tiers (LOW/MEDIUM/HIGH), execution modes (KEEP_SP/REPORT_LOCAL_SQL/REPORT_SCOPED_QUERY), and provenance tracking. |
| [`schema-discovery`](schema-discovery.md) | Confirm objects/columns from evidence, not assumption. |
| [`basic-query-generation`](basic-query-generation.md) | Minimal read-only SELECT for simple pulls. |
| [`business-logic-discovery`](business-logic-discovery.md) | 7-level progressive reference logic discovery; strictly treats similar columns as non-authoritative. |
| [`report-reference-analysis`](report-reference-analysis.md) | Extract logic from a reference report/RDL. |
| [`sql-generation`](sql-generation.md) | Compose correct, minimal SQL and REPORT_SCOPED_QUERY in the right dialect. |
| [`query-validation`](query-validation.md) | Dialect, references, joins, read-only safety. |
| [`adhoc-data-pull`](adhoc-data-pull.md) | Read-only ad-hoc retrieval workflow. |
| [`ssrs-parameter-query`](ssrs-parameter-query.md) | Value/label lookup queries for SSRS parameters. |
| [`sql-server`](sql-server.md) | T-SQL dialect specifics. |
| [`databricks`](databricks.md) | Databricks SQL / catalog.schema specifics. |
| [`impact-analysis`](impact-analysis.md) | Dependencies affected by a SQL object change. |

Handoffs from SSRS follow the [agent handoff contract](../../instructions/agent-handoff.md).
