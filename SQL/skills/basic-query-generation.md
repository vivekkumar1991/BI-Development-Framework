# Skill: basic-query-generation

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** operating mode is READ_ONLY and the request is BASIC_PULL.

## Purpose

Produce the **simplest** read-only query that returns exactly what was asked.

## Rules

- `SELECT` **only the requested columns** (no `SELECT *`).
- Add **only the requested filters**; no extra predicates.
- **No unnecessary joins**, subqueries, or CTEs.
- **No invented business logic**, calculations, or derived columns unless requested.
- Schema-qualify objects; parameterize any user-supplied filter value.
- Use the resolved dialect ([`sql-server`](sql-server.md) / [`databricks`](databricks.md)).
- Use only objects confirmed in the locked Active Data Source Context.

## Example shape

```sql
SELECT CustomerID, CustomerName, Region
FROM   dbo.Customer;      -- add WHERE only if a filter was requested
```

## Output

A minimal `SELECT`, ready for [`query-validation`](query-validation.md).
