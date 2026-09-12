# SSRS Skills

Modular, domain-specific skills for the [SSRS Agent](../../agents/ssrs-agent.md). Each skill
is **behavior only** — general security, Git, documentation, and validation *policy* lives in
the canonical [`instructions/`](../../instructions/) and is referenced, not restated.

**Load only the skills a request needs** (token efficiency). Typical bundles:

| Request | Skills |
|---------|--------|
| Simple formatting | `rdl-analysis`, `rdl-minimal-editing`, `formatting`, `validation` |
| Show/hide item | `rdl-analysis`, `rdl-minimal-editing`, `visibility`, `validation` |
| New parameter + lookup | `rdl-analysis`, `parameters`, `datasets`, `ssrs-parameter-query` (SQL handoff), `validation` |
| Add/modify tablix column | `rdl-analysis`, `tablix`, `expressions`, `rdl-minimal-editing`, `validation` |
| Drillthrough / navigation | `rdl-analysis`, `drillthrough-navigation`, `impact-analysis`, `validation` |
| Subreport | `rdl-analysis`, `subreports`, `impact-analysis`, `validation` |
| Optimize rendering | `rdl-analysis`, `pagination-rendering`, `impact-analysis`, `validation` |

## Catalog

| Skill | Purpose |
|-------|---------|
| [`report-discovery`](report-discovery.md) | Locate the target `.rdl` under `projectRoot`; disambiguate. |
| [`rdl-analysis`](rdl-analysis.md) | Read an RDL's structure, datasets, params, items, references. |
| [`rdl-minimal-editing`](rdl-minimal-editing.md) | Apply the smallest patch; preserve everything unrelated. |
| [`parameters`](parameters.md) | Free-form vs selectable report parameters and schema-aware layout synchronization. |
| [`datasets`](datasets.md) | Embedded/shared datasets, fields, query binding. |
| [`tablix`](tablix.md) | Tables/matrices/lists: rows, columns, groups, cells. |
| [`expressions`](expressions.md) | SSRS/VB expressions, aggregates, field references. |
| [`formatting`](formatting.md) | Number/date formats, styles, colors, fonts. |
| [`visibility`](visibility.md) | Show/hide, toggles, conditional visibility. |
| [`drillthrough-navigation`](drillthrough-navigation.md) | Actions, drillthrough, bookmarks, links. |
| [`subreports`](subreports.md) | Subreport items and parameter passing. |
| [`pagination-rendering`](pagination-rendering.md) | Page breaks, size/margins, render performance. |
| [`impact-analysis`](impact-analysis.md) | Dependencies affected before structural/destructive change. |
| [`validation`](validation.md) | Pre-flight schema-aware structural checks, parameter layout reconciliation, and risk gating. |

See the [agent handoff contract](../../instructions/agent-handoff.md) for SSRS → SQL work.
