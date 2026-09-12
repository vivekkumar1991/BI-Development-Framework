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
5. **Schema-aware metadata synchronization:** when adding, renaming, or removing parameters in
   a 2016/01 schema RDL with `<ReportParametersLayout>`, keep `<CellDefinitions>` synchronized
   in lockstep. Never introduce layout elements into 2010/01 or older schemas, and never upgrade
   the RDL schema version.
6. Edit **in place** at the path under `projectRoot` (visible immediately in SSDT).
7. After editing, expect a **narrow diff** — a broad diff is a red flag; stop and review.

## Change Scope & Diff Guard (Phase 8)

For any report-local SQL or structural change, validate the diff boundary before accepting the patch:

### Expected Diff Scope (Allowed):
- Target `<DataSet>` query node (`<CommandText>`, `<CommandType>`).
- Target `<DataSet>` `<Fields>` list (new/modified fields required by the change only).
- Associated parameter or layout definitions explicitly requested.

### Unexpected Diff Scope (Strictly Blocked $\rightarrow$ `REVIEW_REQUIRED`):
- Unrelated datasets or data sources.
- Unrelated parameters or parameter panel layout cells.
- Report layout items (Tablix, Rectangle, Chart, Matrix) unless explicitly requested.
- Page dimensions, margins, headers, footers, or orientation.
- Formatting styles (font, color, borders, padding) of unrelated textboxes.
- Unrelated expressions, filters, groups, or actions.
- Solution/project files (`.rptproj`, `.sln`).
- Workspace configuration files (`workspace.config.json`).
- Unrelated framework files.

*Any unexpected diff beyond the strict target scope halts the workflow with `REVIEW_REQUIRED`.*
5. **Preserve the RDL schema version.** Never introduce an element from a newer RDL schema
   (detected via the root namespace) than the file declares, and never change that namespace,
   unless the user explicitly requests a schema migration. Validate with
   [`../validation/Validate-RdlSchema.ps1`](../validation/Validate-RdlSchema.ps1).
6. Edit **in place** at the path under `projectRoot` (visible immediately in SSDT).
7. After editing, expect a **narrow diff** — a broad diff is a red flag; stop and review.

## Output

A minimal, in-place RDL patch plus a one-line-per-change summary. Validate with
[`validation`](validation.md); references: [`instructions/validation.md`](../../instructions/validation.md).
