# PowerBI Workspace

Workspace for **Power BI** artifacts produced through the framework (datasets, measures,
model docs, report specs). **Empty by design** — no business reports are created until
explicitly requested.

- Entry point for any work: the [Router Agent](../agents/router-agent.md).
- Specialist: the [Power BI Agent](../agents/powerbi-agent.md).
- Scaffolds to start from: [`../templates/powerbi/`](../templates/powerbi/).

Follow the shared [instructions](../instructions/) for standards, security, validation,
documentation, and Git workflow. Do not connect to production or deploy from here.
