# Skill: rdl-minimal-editing

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** modifying any existing `.rdl`.

## Purpose

Apply the **smallest possible patch** to satisfy the request. **Never regenerate the whole
RDL** when a targeted change is possible.

## Rules

1. Change only the node(s) required by the request.
2. **Preserve everything unrelated:** XML structure & ordering, namespaces, report items,
   expressions, datasets, parameters, layout, **names/IDs**, and formatting.
3. Match the file's existing indentation/style; do not reformat untouched regions.
4. Keep GUIDs/`rd:` designer attributes intact unless the change specifically requires them.
5. Edit **in place** at the path under `projectRoot` (visible immediately in SSDT).
6. After editing, expect a **narrow diff** — a broad diff is a red flag; stop and review.

## Output

A minimal, in-place RDL patch plus a one-line-per-change summary. Validate with
[`validation`](validation.md); references: [`instructions/validation.md`](../../instructions/validation.md).
