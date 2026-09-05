# SQL Workspace

Workspace for **SQL** artifacts produced through the framework (queries, stored procedures,
views, functions, migrations). **Empty by design** — nothing is created until requested.

- Entry point for any work: the [Router Agent](../agents/router-agent.md).
- Specialist: the [SQL Agent](../agents/sql-agent.md).
- Scaffolds to start from: [`../templates/sql/`](../templates/sql/).

Follow the shared [instructions](../instructions/) for standards, security, validation,
documentation, and Git workflow. All SQL must be parameterized and set-based; never run
against a production database or execute destructive statements outside an approved
non-production context.
