# Skill: sql-generation

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** composing non-trivial SQL (REFERENCE_LOGIC or multi-part output).

## Purpose

Assemble correct, **minimal** SQL from discovered schema + located logic.

## Rules

- Start from the confirmed objects/columns and the extracted logic; add only what was asked.
- Prefer set-based, sargable predicates; qualify all objects; parameterize inputs.
- Introduce joins/CTEs **only** when the requested result genuinely needs them; avoid
  duplicate-amplifying joins (verify grain).
- Preserve the reference logic's semantics exactly; **never invent** rules.
- Emit in the resolved dialect ([`sql-server`](sql-server.md) / [`databricks`](databricks.md)).

## Output

A minimal, correct query for [`query-validation`](query-validation.md), with a one-line note
on any reused logic and its source.
