# Skill: sql-server

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** the resolved engine is SQL Server.

## Purpose

Apply T-SQL dialect specifics.

## Notes

- Identifiers: `[schema].[object]`; string literals in single quotes; `N'...'` for Unicode.
- Paging: `OFFSET ... FETCH NEXT ... ROWS ONLY` (with `ORDER BY`); `TOP (n)` for simple limits.
- Params: `@name`; declare with `DECLARE`; parameterized filters, never string-built SQL.
- Common functions: `ISNULL`, `COALESCE`, `TRY_CONVERT`, `FORMAT`, `DATEADD`, `DATEDIFF`.
- Schema lookups: `INFORMATION_SCHEMA.*`, `sys.objects`, `sys.columns` (read-only).

## Output

Dialect-correct T-SQL. Read-only for data pulls (see
[`query-validation`](query-validation.md)).
