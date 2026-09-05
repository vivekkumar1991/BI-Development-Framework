# Skill: impact-analysis

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** before any structural or destructive RDL change.

## Purpose

Identify what a change will affect so nothing breaks silently.

## Check dependencies

- **Fields** used by tablix cells, expressions, groups, sorts, filters.
- **Datasets** referenced by items, parameters (available/default values), and subreports.
- **Parameters** referenced by dataset queries, filters, visibility, and actions.
- **Named items** referenced by `ToggleItem`, `BookmarkLink`, drillthrough targets.
- Renaming/removing any of the above ripples — list every referrer before proceeding.

## Output

A short impact list (what depends on the target, what must change together). If the blast
radius is larger than the request implies, **stop and confirm**. Pairs with
[`rdl-minimal-editing`](rdl-minimal-editing.md).
