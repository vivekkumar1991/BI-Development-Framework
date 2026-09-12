# Skill: rdl-analysis

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** understanding an RDL before editing, debugging, pre-flight validation, or analysis.

## Purpose

Build an accurate picture of the report's structure, schema version, and metadata relationships
so edits stay targeted and pre-flight validation rules can be accurately applied.

## Inspect

- **RDL namespace and schema version** (e.g. `2016/01`, `2010/01`, `2008/01`, `2005/01`).
- **DataSources** and **DataSets** (queries, command type, command text, fields, query parameters).
- **ReportParameters** (names, data types, defaults, available values, prompts, nullable/multi-value).
- **ReportParametersLayout** (if present in 2016/01 schemas: grid dimensions, cell definitions, parameter name bindings, cell coordinates).
- **Report items** (Tablix, Textbox, Image, Subreport, Rectangle) and their names/IDs/DataSetName bindings.
- **Expressions** (`=Fields!...`, `=Parameters!...`, aggregates, `ReportItems`).
- **Groups, filters, sorting, actions** (drillthrough/navigation), visibility rules.
- Overall XML shape and parent/child hierarchies.

## Output

A concise map: schema version ↔ datasets ↔ fields ↔ items ↔ parameters ↔ parameter layout cells ↔ actions, plus the exact node(s)
the requested change will touch. Feeds [`impact-analysis`](impact-analysis.md),
[`rdl-minimal-editing`](rdl-minimal-editing.md), and [`validation`](validation.md).
