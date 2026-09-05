# Skill: report-discovery

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** the target `.rdl` must be located before any edit.

## Purpose

Find the correct `.rdl` under the configured `projectRoot` without guessing.

## Steps

1. Read `SSRS/workspace.config.json`; use `projectRoot` (never ask again if set).
2. Enumerate `.rdl` files under `projectRoot` (recursively).
3. Match against the request by report name, folder, and hints in the brief.
4. If **one** clear match — proceed. If **several equally plausible**, list them and
   **ask the user to choose**. If **none**, report and ask.
5. Confirm the chosen `.rdl` exists and is inside `projectRoot` before handing to editing.

## Output

The absolute path of the confirmed target `.rdl` (inside `projectRoot`).

Scope and secrets: [`security.md`](../../instructions/security.md).
