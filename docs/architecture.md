# Architecture

This document describes the design of the AI-Assisted BI Development Framework. It is the
living reference behind the initial scaffold.

## Purpose

Provide a **reusable, AI-assisted** way to develop and maintain BI work across **Power BI**,
**SSRS**, and **SQL**, with consistent standards, validation, documentation, and Git-based
version control — and a clear path to **add more technologies later**.

## Design principles

- **Single entry point.** Every request goes through the Router Agent.
- **Separation of concerns.** Routing, specialist work, and validation are distinct roles.
- **Shared rules, not copy-paste.** Standards live once in `instructions/` and are referenced.
- **Safe by default.** No production access, no deployment, no auto-commit.
- **Extensible.** New technologies/agents follow a documented pattern.

## Components

### Agents (`agents/`)
- **Router Agent** — entry point. Identifies **technology** (Power BI / SSRS / SQL) and
  **task** (Create / Modify / Analyze / Debug / Optimize), loads shared rules, and routes.
- **Specialist agents** — `powerbi-agent`, `ssrs-agent`, `sql-agent`. Do the actual work for
  their technology across all five task types.
- **Validation Agent** — common quality gate run after specialist work; reports pass/fail.

### Shared instructions (`instructions/`)
`development-standards` · `git-workflow` · `security` · `validation` · `documentation` —
technology-agnostic rules every agent follows.

### Templates (`templates/`)
Reusable structural scaffolds (agent blueprint + per-technology templates). Not business
reports.

### Workspaces (`PowerBI/`, `SSRS/`, `SQL/`)
Where produced artifacts will live. Empty until work is explicitly requested.

### Docs (`docs/`)
Architecture, getting started, and the extension guide.

## Control flow

```
User ─▶ Router ─▶ (identify technology + task) ─▶ load shared instructions
     ─▶ Specialist agent (build/modify/analyze/debug/optimize)
     ─▶ Validation Agent (PASS / FAIL report)
     ─▶ Router (documentation + git workflow, user-gated commit/deploy)
     ─▶ User (reviews, then commits/deploys if desired)
```

## Guardrails

Enforced across the framework; defined once in
[`../instructions/security.md`](../instructions/security.md) and
[`../instructions/git-workflow.md`](../instructions/git-workflow.md): `README.md` never
modified, no production database connections, no deployment, no commit/push unless the user
asks, no secrets/connection strings in the repo, and no business reports unless explicitly
requested.

## Extensibility model

Adding a technology (e.g., Tableau, dbt, SSIS) means: a new workspace folder, a new
`agents/<tech>-agent.md` from the [agent template](../templates/agent-template.md), a new
`templates/<tech>/` folder, and a new row in the Router's routing map. The shared
instructions and Validation Agent apply unchanged. See
[`extending-the-framework.md`](extending-the-framework.md).
