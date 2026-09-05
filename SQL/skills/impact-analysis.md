# Skill: impact-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** modifying an existing SQL object (view/proc/function) rather than a pull.

## Purpose

Understand what depends on an object before changing it.

## Check dependencies

- Callers/consumers of the object (other procs/views, reports' dataset queries).
- Output **contract**: column names, types, and order that downstream consumers rely on.
- Parameters/filters whose meaning would change.
- For SQL Server, dependency views (`sys.sql_expressions_referencing`); for Databricks, known
  consumers/lineage — read-only.

## Output

A short list of affected consumers and any contract that must be preserved. If a change breaks
a consumer's expectations, **flag it** before proceeding. Pairs with
[`query-validation`](query-validation.md).
