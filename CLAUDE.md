# CLAUDE.md — AI Session Orientation

> This file orients any AI assistant working in this repository.
> **Do not modify `README.md`.** Its content is authoritative and owned by the project.

## What this repository is

An **AI-assisted BI Development Framework** that standardizes how AI agents help build,
modify, analyze, debug, and optimize work across three technologies:

- **Power BI**
- **SSRS** (SQL Server Reporting Services)
- **SQL**

The framework is agent-driven, template-based, and Git-versioned. It is designed to be
**extended** with additional BI technologies and agents over time.

## Start here: the Router Agent

**Every task enters through the Router Agent.** Do not jump straight to a specialist.

1. Read [`agents/router-agent.md`](agents/router-agent.md).
2. The Router identifies the **technology** (Power BI / SSRS / SQL) and the **task**
   (Create / Modify / Analyze / Debug / Optimize).
3. It hands off to the matching specialist agent in [`agents/`](agents/).
4. Specialist output is validated by the [Validation Agent](agents/validation-agent.md)
   (read-only Analyze work excepted).

## Shared rules (apply to every task)

Before doing any work, load and follow the shared instructions in [`instructions/`](instructions/):

- [Development standards](instructions/development-standards.md)
- [Git workflow](instructions/git-workflow.md)
- [Security](instructions/security.md)
- [Validation](instructions/validation.md)
- [Documentation](instructions/documentation.md)

## Hard guardrails

- **Never** modify or delete `README.md`.
- **Never** connect to production databases.
- **Never** deploy anything.
- **Never** commit or push unless the user explicitly asks.
- **Never** store secrets or connection strings in the repository.
- Do **not** create business reports unless explicitly requested; the framework ships with
  structural templates only.

## Map of the repository

| Path | Purpose |
|------|---------|
| `agents/` | Router, specialist, and validation agent definitions |
| `instructions/` | Shared, technology-agnostic standards |
| `templates/` | Reusable structural scaffolds (not business reports) |
| `PowerBI/`, `SSRS/`, `SQL/` | Workspaces for future artifacts (empty for now) |
| `docs/` | Architecture, getting started, and extension guides |

To add a new technology or agent, follow
[`docs/extending-the-framework.md`](docs/extending-the-framework.md).
