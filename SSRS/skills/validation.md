# Skill: validation

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** after an RDL edit, before handing to the Validation Agent.

## Purpose

Run **focused structural** RDL checks (visual/render stays a developer/SSDT step).

## Checks

- [ ] `.rdl` is **valid XML**; RDL **namespace preserved**.
- [ ] Expected node(s) for the change exist and are well-formed.
- [ ] **Parameter**, **dataset**, and **data-source** references resolve.
- [ ] **Field** references resolve where statically checkable.
- [ ] **Group / filter / action** (drillthrough/navigation/toggle/bookmark) references coherent.
- [ ] Report-item dimensions/positions valid; tablix row/column/cell counts consistent.
- [ ] **Unexpected broad diff rejected** — only intended nodes changed.

## Output

A pass/fail structural report feeding the [Validation Agent](../../agents/validation-agent.md).
Canonical checklist: [`instructions/validation.md`](../../instructions/validation.md).
