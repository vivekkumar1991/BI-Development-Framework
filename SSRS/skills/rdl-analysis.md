# Skill: rdl-analysis

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** understanding an RDL before editing, debugging, or analysis.

## Purpose

Build an accurate picture of the report's structure so edits stay targeted.

## Inspect

- **DataSources** and **DataSets** (queries, command type, fields).
- **ReportParameters** (data types, defaults, available/valid values, prompts).
- **Report items** (Tablix, Textbox, Image, Subreport, Rectangle) and their names/IDs.
- **Expressions** (`=Fields!...`, aggregates, `ReportItems`, parameters).
- **Groups, filters, sorting, actions** (drillthrough/navigation), visibility rules.
- RDL **namespace/version** and overall XML shape.

## Output

A concise map: datasets ↔ fields ↔ items ↔ parameters ↔ actions, plus the exact node(s)
the requested change will touch. Feeds [`impact-analysis`](impact-analysis.md) and
[`rdl-minimal-editing`](rdl-minimal-editing.md).
