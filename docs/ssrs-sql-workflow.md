# SSRS + SQL Development Workflow

Concise map of how the [SSRS Agent](../agents/ssrs-agent.md) and [SQL Agent](../agents/sql-agent.md)
work and cooperate. Behavior detail lives in the skills ([`SSRS/skills/`](../SSRS/skills/README.md),
[`SQL/skills/`](../SQL/skills/README.md)); policy lives in [`instructions/`](../instructions/).
This page does not restate either.

## 1. SSRS Agent workflow

Classify → resolve `workspace.config.json` (`projectRoot`) → **discover** the target `.rdl`
(disambiguate if needed) → **analyze** it and its dependencies → apply the **smallest RDL
patch in place** → **structural validation** → Validation Agent → concise change summary.
Never edits outside `projectRoot`; never regenerates a whole RDL.

## 2. SQL Agent workflow

Classify **mode** → **resolve connection** → **discover schema/source** → generate the
**minimum SQL** in the correct dialect → **validate (read-only)** → return query + evidence.
Never modifies RDL; never invents business logic.

## 3. SSRS → SQL handoff

The SSRS Agent owns RDL edits; when it needs a query it hands off using the compact
[handoff contract](../instructions/agent-handoff.md) (mode, purpose, value/label field,
source evidence, engine, logical profile, database/schema, constraints — **no secrets**).
The SQL Agent returns the query + validation; the SSRS Agent wires it into the RDL.

## 4. BASIC_PULL

Simple ad-hoc retrieval → a minimal read-only `SELECT`: only requested columns/filters, no
unnecessary joins/CTEs, no invented logic.

## 5. REFERENCE_LOGIC

Reuse existing approved logic from a named report/RDL/object: locate it, extract it, translate
SSRS/VB expressions to SQL preserving semantics, add only what's requested. If it can't be
found, **ask** — never invent.

## 6. SSRS_SUPPORT

Query support for the SSRS Agent (e.g. parameter available-values): small read-only lookup
with value/label fields, `DISTINCT`/deterministic ordering where appropriate. No RDL edits.

## 7. Connection resolution

Priority: **RDL data-source evidence → developer-local logical profile → user clarification**
(never guess). Model: `Logical Data Source → Connection Profile → Physical Environment`. The
repo stays environment-independent; physical endpoints live only in developer-local config.

## 8. Local configuration

`SSRS/workspace.config.json` (gitignored) holds `projectRoot`, `logicalDataSources`, and
`connectionProfiles` (names/metadata only). Copy from
[`workspace.config.example.json`](../SSRS/workspace.config.example.json). **No secrets** — prefer
Windows auth / SSO / env vars / OS credential manager / org secret provider; never paste
passwords or tokens into chat.

## 9. SQL Server vs Databricks

Both engines are supported. The resolved profile's `engine` selects the dialect skill
([`sql-server`](../SQL/skills/sql-server.md): T-SQL, `[schema].[obj]`, `OFFSET/FETCH`) or
([`databricks`](../SQL/skills/databricks.md): `catalog.schema.table`, `LIMIT`).

## 10. Parameter workflow

New parameter → **free-form** (create only the `ReportParameter`) or **selectable** (reuse a
dataset, else SSRS_SUPPORT handoff). Wire available/value/label; add **filtering only when
explicitly requested** — a parameter does not imply filtering. If ambiguous, ask first.

## 11. Business-logic reference workflow

REFERENCE_LOGIC: inspect the reference report's dataset query, calculated fields, expressions,
filters, parameters, and data source; reuse the exact rule; **don't copy unrelated
complexity**; never invent.

## 12. Security boundary

No production connections; no deploy; no auto-commit; no secrets in Git; developer-local
values stay in the gitignored config. Canonical: [`security.md`](../instructions/security.md).

## 13. Validation boundary

AI does **structural** RDL validation and **read-only** SQL validation; **visual/render**
verification of SSRS is a developer/SSDT step. Canonical: [`validation.md`](../instructions/validation.md).
