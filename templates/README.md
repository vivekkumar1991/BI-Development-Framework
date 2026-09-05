# Templates

Reusable **structural scaffolds** for the framework. These are generic blueprints — **not
business reports and not real data.** Copy a template into the appropriate workspace folder
(`PowerBI/`, `SSRS/`, `SQL/`) and fill it in for a specific task.

## Contents

| Path | Purpose |
|------|---------|
| [`agent-template.md`](agent-template.md) | Blueprint for authoring a new agent |
| `powerbi/` | Power BI scaffolds (measure, model doc, naming) |
| `ssrs/` | SSRS scaffolds (report spec, parameters) |
| `sql/` | SQL scaffolds (stored procedure, view, migration) |

## Rules

- Templates contain **placeholders** (`<...>`) only — no real business logic, no PII, no
  connection strings.
- Keep templates aligned with [`../instructions/development-standards.md`](../instructions/development-standards.md).
- When you add a template, note it in this README.

## Adding a template for a new technology

Create `templates/<technology>/` with the same spirit of scaffolds, then reference it from the
matching specialist agent. See [`../docs/extending-the-framework.md`](../docs/extending-the-framework.md).
