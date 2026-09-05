# Skill: parameters

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding or changing a report parameter.

## Purpose

Create/modify `ReportParameter`s correctly, distinguishing input styles.

## Decide the style

- **Free-form input** — user types a value. Create only the required `ReportParameter`
  (data type, prompt, default/nullable/multi-value as requested). Nothing else.
- **Selectable (from a list)** — values come from a set:
  1. Inspect existing datasets first; reuse one if it can safely supply the values.
  2. If none fits, hand off to the SQL Agent in **SSRS_SUPPORT** mode via
     [`agent-handoff.md`](../../instructions/agent-handoff.md) (value field, label field,
     source evidence, engine, profile — **no secrets**).

## Wiring

After the query is available, set `AvailableValues` (value + label), defaults, and prompt.
Bind report **filtering/query** to the parameter **only when explicitly requested** — creating
a parameter does not imply filtering. If ambiguous, **ask first**.

## Output

A minimal parameter patch. See also [`datasets`](datasets.md),
[`ssrs-parameter-query`](../../SQL/skills/ssrs-parameter-query.md).
