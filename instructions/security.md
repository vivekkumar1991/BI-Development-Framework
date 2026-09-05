# Security

Security rules that apply to every task in this framework. The Validation Agent treats
violations here as **BLOCKERs**.

## Non-negotiable rules

- **No production databases.** Never connect to, query, or run anything against a production
  data source. Work against provided samples, schemas, or specifications.
- **No secrets in the repository.** No passwords, API keys, tokens, or connection strings —
  in files, code, comments, or commit history.
- **No deployment.** Never publish, deploy, or push artifacts to any server or service.
- **Least privilege.** Design objects and access assuming the minimum permissions necessary.

## Connection strings & credentials

- Reference connections by **named placeholders**, never literal values:
  `<CONNECTION_STRING>`, `<SERVER>`, `<DATABASE>`, `<USERNAME>`.
- Real values belong in environment variables, a secrets manager, or the platform's
  credential store — **never** in the repo.
- Developer-specific local values (project paths, server names, local config) live only in a
  gitignored local file (e.g. `SSRS/workspace.config.json`) — never committed.
- SSRS: use shared/stored data sources with server-managed credentials; never embed credentials
  in an `.rdl`.
- Power BI: manage gateway/credentials in the Service, not in committed files.

## Injection & query safety

- **All SQL and SSRS dataset queries must be parameterized.** Never concatenate user input
  into a query string.
- Validate and constrain parameters (type, range, allowed values).

## Data handling & PII

- Do not commit real business data, extracts, or PII into the repository.
- Use synthetic or anonymized sample data for examples and templates.
- Mask or omit sensitive columns in documentation and samples.
- Consider row-level security (Power BI RLS / filtered views) where data is sensitive.

## Destructive operations

- No `DROP`, `DELETE`, `TRUNCATE`, or unqualified `UPDATE` except in an explicit,
  user-approved, **non-production** context.
- Always scope writes with an explicit `WHERE` clause and review before execution.

## If a violation is found

Stop, flag it as a BLOCKER, and report it through the Validation Agent to the Router. Do not
proceed until it is resolved.
