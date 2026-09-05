# Skill: query-validation

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** after generating any SQL, before handing off.

## Purpose

Statically check the query for correctness and safety (canonical list:
[`instructions/validation.md`](../../instructions/validation.md)).

## Checks

- [ ] Correct **dialect** for the resolved engine.
- [ ] Referenced **objects/columns** exist per discovered schema.
- [ ] **Parameter placeholders** correct; no **ambiguous** (unqualified) columns.
- [ ] No unintended **Cartesian** joins; no **duplicate amplification** (grain preserved).
- [ ] **Filter correctness** and **null behavior** sound.
- [ ] **Read-only safety:** no `INSERT/UPDATE/DELETE/MERGE/DROP/ALTER/TRUNCATE` in data-pull
      work.
- [ ] Objects **schema-qualified**; inputs **parameterized**.

## Output

A pass/fail note + evidence (objects referenced, dialect, read-only) for the
[Validation Agent](../../agents/validation-agent.md).
