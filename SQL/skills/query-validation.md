# Skill: query-validation

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** after generating any SQL, before handing off.

## Purpose

Statically check the query for correctness and safety (canonical list:
[`instructions/validation.md`](../../instructions/validation.md)).

## Checks

- [ ] Operating mode is explicit: READ_ONLY or SQL_GENERATION.
- [ ] Correct **dialect** for the resolved engine.
- [ ] Referenced **objects/columns** exist per discovered schema.
- [ ] **Parameter placeholders** correct; no **ambiguous** (unqualified) columns.
- [ ] No unintended **Cartesian** joins; no **duplicate amplification** (grain preserved).
- [ ] **Filter correctness** and **null behavior** sound.
- [ ] **Read-only safety:** no `INSERT/UPDATE/DELETE/MERGE/DROP/ALTER/TRUNCATE` in data-pull
      work.
- [ ] Objects **schema-qualified**; inputs **parameterized**.
- [ ] Every referenced table, view, procedure, catalog, report reference, and business-logic
      source belongs to the locked **Active Data Source Context**. No silent cross-server,
      cross-database/catalog, or cross-data-source mixing.
- [ ] **Context lock:** exactly one Active Data Source Context was resolved for the task and it
      remained unchanged. Each table, view, stored procedure, report/RDL, Catalog record, SQL
      definition, and business-logic evidence was admitted only after its known source metadata
      matched that lock; missing or conflicting metadata stopped for clarification.
- [ ] **Catalog discovery:** each result is targeted, carries its Catalog binding and Active Data
      Source Context evidence, follows RDL → active Catalog → same-context report precedence,
      and rejects results that do not belong to the locked context.
- [ ] **REFERENCE_LOGIC:** the Concept Evidence Contract includes its definition evidence,
      status, and dependencies. Conflicting same-context definitions are surfaced for user
      clarification unless authoritative evidence resolves them; insufficient evidence is never
      treated as reusable logic.
- [ ] **READ_ONLY:** no write operation is emitted or executed.
- [ ] **SQL_GENERATION:** output is query-local SQL only; it preserves existing parameters and
      explicitly requested filters, and does not modify a database object, stored procedure, or
      RDL file.
- [ ] **STORED_PROCEDURE_ANALYSIS:** the procedure was read-only; all unavailable facts are
      marked as not discoverable, no semantics were invented, and the contract includes an
      evidence-based conversion class.
- [ ] Any cross-server, cross-database/catalog, or cross-data-source dependency is flagged,
      blocks reuse outside the locked Active Data Source Context, and is classified
      `DO_NOT_AUTO_CONVERT`.
- [ ] **SP_TO_INLINE:** the Stored Procedure Analysis Contract is `SAFE_CANDIDATE`; generated
      report-local SQL is read-only, preserves the observed result-set semantics and parameter
      mapping, applies only the requested change, and remains inside the locked Active Data
      Source Context.
- [ ] **SP_TO_INLINE:** `REVIEW_REQUIRED` has no generated inline SQL or RDL change, and
      `DO_NOT_AUTO_CONVERT` has no generated inline SQL, RDL change, or automatic conversion.

## Output

A pass/fail note + evidence (Active Data Source Context, objects referenced, dialect,
read-only) for the
[Validation Agent](../../agents/validation-agent.md).
