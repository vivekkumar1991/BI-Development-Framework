# Skill: request-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** the first step of every SQL request.

## Purpose

Classify the request into exactly one mode and decide which skills to load.

## Classify

- **BASIC_PULL** — plain retrieval of named columns/filters, no business rules.
- **REFERENCE_LOGIC** — request references existing business logic ("same X logic as report Y").
- **SSRS_SUPPORT** — an SSRS Agent handoff (parameter values, dataset query work).

## Extract

- Required output (columns/result shape), filters, ordering, DISTINCT need.
- Engine + connection hints (from an RDL handoff or the request).
- Any named reference report/object for REFERENCE_LOGIC.

## Output

Chosen mode + a short parameter list feeding
[`connection-resolution`](connection-resolution.md) and the mode's generation skill. Keep
simple requests simple — do not escalate a BASIC_PULL into logic it didn't ask for.
