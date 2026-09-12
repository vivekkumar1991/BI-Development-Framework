# Skill: adhoc-data-pull

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** a user asks for READ_ONLY ad-hoc data (usually BASIC_PULL).

## Purpose

Deliver a one-off, **read-only** result set safely and simply.

## Steps

1. Confirm requested columns, filters, ordering, and row expectations.
2. Resolve and preserve the locked Active Data Source Context
   ([`connection-resolution`](connection-resolution.md)); confirm objects only within it
   ([`schema-discovery`](schema-discovery.md)).
3. Generate a minimal `SELECT` ([`basic-query-generation`](basic-query-generation.md)).
4. Validate ([`query-validation`](query-validation.md)); ensure **read-only**.
5. Execute only when approved read-only database access is available; otherwise return the
   query and inspection evidence without execution.

## Guardrail

Never generate writes for data pulls. No production connections. See
[`security.md`](../../instructions/security.md).
