# Development Standards

Shared, technology-agnostic standards for all work in this framework. Specialist agents load
the relevant section before producing anything; the Validation Agent checks against it.

## Universal principles

- **Clarity over cleverness.** Readable, maintainable artifacts win.
- **DRY / reuse.** Reuse existing templates, measures, views, and patterns before creating new
  ones. Check `templates/` and existing workspace artifacts first.
- **Single responsibility.** Each object (measure, dataset, proc, report) does one thing well.
- **Explicit over implicit.** Name things fully; avoid ambiguous abbreviations.
- **Small, reviewable changes.** Prefer incremental changes with clear intent.
- **Match the surroundings.** New code should read like the code already in the workspace.

## Naming conventions

| Item | Convention | Example |
|------|-----------|---------|
| Folders (workspaces) | Technology name as given | `PowerBI/`, `SSRS/`, `SQL/` |
| Files | `kebab-case` for docs, technology-native for artifacts | `sales-summary.rdl` |
| SQL objects | `PascalCase`, schema-qualified | `sales.uspGetOrders` |
| SQL stored procedures | `usp` prefix | `uspCalculateMargin` |
| SQL views | `vw` prefix | `vwActiveCustomers` |
| Power BI measures | Business-friendly, spaced | `Total Sales`, `Sales YoY %` |
| Power BI columns | `PascalCase`, no redundant table prefix | `OrderDate` |
| SSRS parameters | `PascalCase` | `StartDate`, `RegionId` |

## Per-technology standards

### Power BI
- Measures over calculated columns where possible; document each measure's intent.
- Use variables (`VAR`) in DAX for readability and to avoid recomputation.
- Keep Power Query steps named and folding-friendly.
- Consider RLS from the start when data is sensitive.

### SSRS
- One dataset per logical need; parameterize all filters.
- Provide sensible parameter defaults and validation.
- Keep expressions simple; push logic to the SQL layer where it belongs.
- Stored Procedure datasets: treat procedures as immutable shared dependencies; implement report-specific changes as report-local inline SQL when classified `SAFE_CANDIDATE`.

### SQL
- **Parameterized** always; never concatenate input into SQL.
- **Set-based** over cursors/row-by-row unless justified.
- Schema-qualify object references (`schema.object`).
- **Stored Procedures are immutable shared dependencies:** never `ALTER`, `CREATE OR ALTER`, `CREATE`, or `DROP` shared procedures or database objects. Report-specific changes are implemented query-local or report-local only.
- Include error handling (`TRY...CATCH`) and explicit transactions for multi-statement writes.
- Write **sargable** predicates; avoid wrapping filtered columns in functions.

## Definition of done

An artifact is "done" only when it is: built to these standards, **validated** (see
[`validation.md`](validation.md)), **documented** (see [`documentation.md`](documentation.md)),
and secure (see [`security.md`](security.md)). Committing/deploying is a separate, user-gated
step — see [`git-workflow.md`](git-workflow.md).
