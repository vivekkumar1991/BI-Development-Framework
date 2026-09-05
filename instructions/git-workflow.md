# Git Workflow

How changes are versioned in this framework. **The default posture is: propose changes, let
the user commit.** Agents never commit, push, or deploy on their own.

## Golden rule

> **Never commit or push unless the user explicitly asks.**
> **Never deploy anything.** Deployment is always a separate, user-driven step.

## Branching

- Work off `main`; create a topic branch for a unit of work.
- Branch naming: `<type>/<technology>-<short-description>`
  - Types: `feature`, `fix`, `refactor`, `docs`, `perf`
  - Examples: `feature/sql-order-margin-view`, `fix/powerbi-sales-yoy`, `docs/framework-setup`
- Keep branches focused and short-lived.

## Commits (when the user asks)

- Small, logical commits — one intent per commit.
- Message style: imperative mood, concise subject, optional body explaining *why*.
  - `Add uspCalculateMargin stored procedure`
  - `Fix Sales YoY % measure to handle first-year nulls`
- Do not mix unrelated changes in one commit.
- **Never commit** secrets, connection strings, `.pbix` data extracts, or credentials.

## Review gates before any commit

1. Work has passed the [Validation Agent](../agents/validation-agent.md) (no BLOCKERs).
2. Documentation is updated ([`documentation.md`](documentation.md)).
3. Security checks pass ([`security.md`](security.md)) — nothing sensitive is staged.
4. `README.md` is unchanged.

## Pull requests

- Open a PR from the topic branch into `main` when the user asks.
- PR description states: what changed, why, which technology/task, and how it was validated.
- Deployment happens only after merge **and** explicit user action — never automatically.

## What agents do vs. what the user does

| Step | Owner |
|------|-------|
| Build + document + validate the artifact | Agent |
| Stage / commit / push | **User (explicit request only)** |
| Open / merge PR | **User** |
| Deploy / publish / refresh | **User** |
