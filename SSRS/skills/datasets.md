# Skill: datasets

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding/changing a dataset, its fields, or its query binding.

## Purpose

Manage embedded/shared datasets and their field lists while keeping queries safe.

## Steps

1. Identify whether the dataset is **embedded** or **shared**; note its `DataSource`.
2. For query changes, hand SQL work to the SQL Agent (SSRS Agent does not author complex SQL
   inline) via [`agent-handoff.md`](../../instructions/agent-handoff.md); wire the returned
   query into the `<CommandText>` and reconcile the `<Fields>` list.
3. Keep queries **parameterized**; map query parameters to report parameters.
4. Preserve existing field names used by report items (renaming a field ripples into
   expressions — check [`impact-analysis`](impact-analysis.md) first).

## Output

A minimal dataset patch with a consistent field list. Query dialect/validation is the SQL
Agent's responsibility; SSRS structural checks via [`validation`](validation.md).
