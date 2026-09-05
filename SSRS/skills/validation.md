# Skill: validation

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** after an RDL edit, before handing to the Validation Agent.

## Purpose

Run **focused structural** RDL checks (visual/render stays a developer/SSDT step).

## Checks

- [ ] `.rdl` is **valid XML**; RDL **namespace preserved**.
- [ ] **Schema-compatible** — no element newer than the RDL's detected schema version was
      introduced (e.g. no 2016/01 `ReportParametersLayout` in a 2010/01 RDL). Run
      [`../validation/Validate-RdlSchema.ps1`](../validation/Validate-RdlSchema.ps1); the
      registry [`rdl-schema-compatibility.json`](../validation/rdl-schema-compatibility.json)
      is the single source of truth. *(BLOCKER if violated — SSDT will reject it)*
- [ ] Expected node(s) for the change exist and are well-formed.
- [ ] **Parameter**, **dataset**, and **data-source** references resolve.
- [ ] **Field** references resolve where statically checkable.
- [ ] **Group / filter / action** (drillthrough/navigation/toggle/bookmark) references coherent.
- [ ] Report-item dimensions/positions valid; tablix row/column/cell counts consistent.
- [ ] **Unexpected broad diff rejected** — only intended nodes changed.

## Output

A pass/fail structural report feeding the [Validation Agent](../../agents/validation-agent.md).
Canonical checklist: [`instructions/validation.md`](../../instructions/validation.md).
