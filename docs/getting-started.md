# Getting Started

How to use the AI-Assisted BI Development Framework.

## 1. Start with the Router

Every request begins at the [Router Agent](../agents/router-agent.md). Describe what you want
in plain language — the Router figures out the rest.

## 2. The Router classifies your request

- **Technology:** Power BI · SSRS · SQL (it will ask if unclear).
- **Task:** Create · Modify · Analyze · Debug · Optimize.

Example prompts:

| You say | Router routes to |
|---------|------------------|
| "Write a stored proc to summarize orders by region" | SQL Agent · Create |
| "This DAX measure returns blanks for the first year" | Power BI Agent · Debug |
| "Make this SSRS report render faster" | SSRS Agent · Optimize |
| "Explain what this view does" | SQL Agent · Analyze |

## 3. The specialist does the work

The matching specialist agent builds the deliverable using the
[templates](../templates/) and follows the shared
[instructions](../instructions/).

## 4. Validation runs automatically

The [Validation Agent](../agents/validation-agent.md) checks the result against standards,
security, and documentation, and returns a **PASS / FAIL** report. Blockers are fixed before
the work is considered done.

## 5. You decide on commit / deploy

The framework **never** commits, pushes, or deploys on its own. When you're happy, follow the
[Git workflow](../instructions/git-workflow.md) and commit/deploy yourself.

## Ground rules you can rely on

- `README.md` is never touched.
- No production database is ever contacted.
- Nothing is deployed automatically.
- No secrets end up in the repo.
- No business report is created unless you ask for one.

## Where things live

- Agents → [`agents/`](../agents/)
- Rules → [`instructions/`](../instructions/)
- Scaffolds → [`templates/`](../templates/)
- Your artifacts → [`PowerBI/`](../PowerBI/), [`SSRS/`](../SSRS/), [`SQL/`](../SQL/)
- Docs → [`docs/`](.)
