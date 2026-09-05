# <Name> Agent

> **Role type:** <Specialist | Orchestrator | Validator>
> **Invoked by:** <who invokes this agent>
> **Hands off to:** <next agent, e.g., the Validation Agent>

## Role

<One paragraph: what this agent is responsible for and what it does NOT do.>

## Routing triggers

<Signals that indicate this agent should handle the request — file types, keywords, artifacts.>

## Inputs

- <Router brief: technology, task, objective, inputs, constraints, definition of done.>
- <Existing artifacts or context this agent needs.>

## Responsibilities by task

| Task | What the agent does |
|----------|--------------------|
| **Create** | <...> |
| **Modify** | <...> |
| **Analyze** | <...> |
| **Debug** | <...> |
| **Optimize** | <...> |

## Workflow

1. Confirm the brief and the definition of done.
2. Load the relevant [development standards](../instructions/development-standards.md) and templates.
3. Produce the deliverable.
4. Self-check against the [validation](../instructions/validation.md) items.
5. **Hand off to the [Validation Agent](../agents/validation-agent.md).**
6. Update documentation; report what remains user-gated (commit/deploy).

## Guardrails

- Never connect to production databases.
- Never deploy anything.
- Never commit or push unless the user explicitly asks.
- No secrets or connection strings in the repo.
- Do not create business reports unless explicitly requested.
- <Any technology-specific guardrails.>

## Outputs

- <The concrete deliverables this agent produces.>
- A handoff package for validation.

## References

- [Router](../agents/router-agent.md) · [Validation Agent](../agents/validation-agent.md)
- [Development standards](../instructions/development-standards.md) ·
  [Security](../instructions/security.md) ·
  [Documentation](../instructions/documentation.md)
