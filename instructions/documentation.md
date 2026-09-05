# Documentation

What must be documented, and where. Documentation is part of the definition of done — the
Validation Agent checks for it.

## Principles

- **Document intent, not mechanics.** Explain *why*, and *what* it's for; the code shows *how*.
- **Keep docs next to the artifact** where practical, and in the workspace folder otherwise.
- **Update docs in the same change** as the code — never leave them stale.

## Artifact headers

Every non-trivial artifact carries a header comment (using the technology's comment syntax):

```
Name        : <object/report/measure name>
Purpose     : <one or two sentences>
Author/Agent: <who/which agent>
Created      : <date>   Last modified: <date>
Inputs       : <parameters / sources>
Outputs      : <result set / visual / report>
Notes        : <assumptions, caveats>
```

## Per-technology documentation

### Power BI
- **Model documentation:** tables, relationships, and key measures with descriptions.
- **Measure documentation:** each measure's purpose and business definition.
- Note any RLS roles and what they restrict.

### SSRS
- **Report spec:** purpose, datasets, parameters (name, type, default), and layout summary.
- Document parameter behavior and any drill-through/subscription intent.

### SQL
- Header comment on procs/views/functions (see above).
- Document parameters, return contract, side effects, and key dependencies.
- Note indexing assumptions and expected data volumes where relevant.

## Change notes

- Record what changed and why with each modification (commit message + artifact header
  `Last modified`).
- For larger efforts, keep a short change log in the relevant workspace folder's README.

## Where docs live

| Doc type | Location |
|----------|----------|
| Framework architecture & guides | `docs/` |
| Shared standards | `instructions/` |
| Artifact-level docs | Header comments + the artifact's workspace folder (`PowerBI/`, `SSRS/`, `SQL/`) |
| Reusable scaffolds | `templates/` |
