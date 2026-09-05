# Agents

This folder holds the agent definitions that drive the BI Development Framework. Agents are
**vendor-neutral markdown specifications** — they can be read by a human, loaded by Claude,
or adapted to any other AI tooling.

## The agent system

```
                        ┌──────────────────┐
   User request  ─────▶ │   Router Agent   │  identifies technology + task
                        └────────┬─────────┘
             ┌───────────────────┼───────────────────┐
             ▼                   ▼                   ▼
     ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
     │ Power BI Agent│  │  SSRS Agent   │  │   SQL Agent   │
     └───────┬───────┘  └───────┬───────┘  └───────┬───────┘
             └───────────────────┼───────────────────┘
                                 ▼
                        ┌──────────────────┐
                        │ Validation Agent │  common, cross-technology checks
                        └──────────────────┘
```

## Files

| File | Role |
|------|------|
| [`router-agent.md`](router-agent.md) | **Entry point.** Identifies technology + task, hands off. |
| [`powerbi-agent.md`](powerbi-agent.md) | Power BI specialist |
| [`ssrs-agent.md`](ssrs-agent.md) | SSRS specialist |
| [`sql-agent.md`](sql-agent.md) | SQL specialist |
| [`validation-agent.md`](validation-agent.md) | Common validator, runs after specialist work |

## Common structure

Every agent follows the blueprint in
[`../templates/agent-template.md`](../templates/agent-template.md):

**Role · Routing triggers · Inputs · Responsibilities · Workflow · Handoffs · Guardrails · Outputs · References**

## Adding a new agent

Copy `../templates/agent-template.md` to `agents/<name>-agent.md`, fill in every section,
then register it in the Router's routing map. See
[`../docs/extending-the-framework.md`](../docs/extending-the-framework.md).
