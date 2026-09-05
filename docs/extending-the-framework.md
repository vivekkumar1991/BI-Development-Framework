# Extending the Framework

The framework is designed to grow. This guide covers the two common extensions: adding a new
**BI technology** and adding a new **agent role**.

## Add a new BI technology

Example: add **Tableau**, **dbt**, or **SSIS**.

1. **Create a workspace folder** at the repo root (e.g., `Tableau/`) with a `README.md`
   modeled on [`../PowerBI/README.md`](../PowerBI/README.md).
2. **Create a specialist agent** at `agents/<tech>-agent.md` by copying
   [`../templates/agent-template.md`](../templates/agent-template.md) and filling in every
   section — including the responsibilities for all five tasks
   (Create / Modify / Analyze / Debug / Optimize).
3. **Add templates** under `templates/<tech>/` for the technology's common artifacts, and
   list them in [`../templates/README.md`](../templates/README.md).
4. **Register it in the Router.** Add the technology to the
   [Router Agent](../agents/router-agent.md):
   - a detection row in the *Identify the technology* table, and
   - a row in the *routing map*.
5. **Extend validation.** Add a technology-specific checklist section to
   [`../instructions/validation.md`](../instructions/validation.md) and to the
   [Validation Agent](../agents/validation-agent.md).
6. **Reuse the shared instructions.** Standards, git-workflow, security, and documentation
   apply unchanged — only add technology-specific notes where truly needed.
7. **Document it.** Update [`architecture.md`](architecture.md) and, if user-facing behavior
   changes, [`getting-started.md`](getting-started.md).

**Do not** modify `README.md`.

## Add a new agent role

Example: a dedicated **Performance Agent** or **Documentation Agent**.

1. Copy [`../templates/agent-template.md`](../templates/agent-template.md) to
   `agents/<name>-agent.md`.
2. Define its role, triggers, workflow, handoffs, and guardrails.
3. Wire it into the flow: update the [Router Agent](../agents/router-agent.md) (and the
   [Validation Agent](../agents/validation-agent.md) if it participates in the quality gate).
4. Note it in [`../agents/README.md`](../agents/README.md) and
   [`architecture.md`](architecture.md).

## Checklist for any extension

- [ ] Follows the [agent template](../templates/agent-template.md) structure.
- [ ] Registered in the Router (detection + routing).
- [ ] Validation coverage added.
- [ ] Templates provided and listed.
- [ ] Docs updated (`architecture.md`, and `getting-started.md` if user-facing).
- [ ] Honors all guardrails (no prod, no deploy, no auto-commit, no secrets, `README.md`
      untouched).
