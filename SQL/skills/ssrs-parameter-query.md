# Skill: ssrs-parameter-query

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** mode is SSRS_SUPPORT — a parameter value/label lookup.

## Purpose

Produce a small read-only lookup for an SSRS parameter's available values. **Do not edit RDL.**

## Steps

1. From the handoff ([`agent-handoff.md`](../../instructions/agent-handoff.md)), take the
   **value field**, **label field**, source evidence, engine, and profile.
2. Resolve connection + confirm the source object/columns.
3. Generate a minimal query returning value + label:
   ```sql
   SELECT DISTINCT CustomerID AS Value, CustomerName AS Label
   FROM   dbo.Customer
   ORDER  BY CustomerName;   -- deterministic ordering
   ```
   Use `DISTINCT` and `ORDER BY` **when appropriate**.
4. Validate ([`query-validation`](query-validation.md)); read-only.

## Output

The query + source evidence returned to the SSRS Agent, which does the RDL wiring. The SQL
Agent **never modifies the RDL**.
