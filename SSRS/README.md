# SSRS Workspace

Workspace for **SSRS** artifacts produced through the framework (report specs, `.rdl`
definitions, dataset queries, parameter designs). **Empty by design** — no business reports
are created until explicitly requested.

- Entry point for any work: the [Router Agent](../agents/router-agent.md).
- Specialist: the [SSRS Agent](../agents/ssrs-agent.md).
- Scaffolds to start from: [`../templates/ssrs/`](../templates/ssrs/).

Follow the shared [instructions](../instructions/) for standards, security, validation,
documentation, and Git workflow. Dataset queries must be parameterized; never embed
credentials. Do not connect to production or deploy from here.
