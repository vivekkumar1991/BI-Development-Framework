# Skill: databricks

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** the resolved engine is Databricks.

## Purpose

Apply Databricks SQL specifics.

## Notes

- Naming: three-level `catalog.schema.table` (Unity Catalog); identifiers in backticks
  `` `col` `` when needed.
- Paging: `LIMIT n` (with `ORDER BY` for determinism); no `TOP`.
- Params: use the caller's parameter marker convention (e.g. named markers / widgets); do not
  string-build SQL.
- Common functions: `COALESCE`, `NVL`, `CAST`/`TRY_CAST`, `date_add`, `datediff`,
  `date_format`.
- Schema lookups: `information_schema.columns`, `DESCRIBE TABLE`, `SHOW COLUMNS` (read-only).

## Output

Dialect-correct Databricks SQL. Read-only for data pulls (see
[`query-validation`](query-validation.md)).
