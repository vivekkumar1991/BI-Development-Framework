# Skill: adhoc-data-pull

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** a user asks for ad-hoc data (usually BASIC_PULL).

## Purpose

Deliver a one-off, **read-only** result set safely and simply.

## Steps

1. Confirm requested columns, filters, ordering, and row expectations.
2. Resolve the connection ([`connection-resolution`](connection-resolution.md)) and confirm
   objects ([`schema-discovery`](schema-discovery.md)).
3. Generate a minimal `SELECT` ([`basic-query-generation`](basic-query-generation.md)).
4. Validate ([`query-validation`](query-validation.md)); ensure **read-only**.
5. Return the query + a note that running it against a real DB is user-gated.

## Guardrail

Never generate writes for data pulls. No production connections. See
[`security.md`](../../instructions/security.md).
