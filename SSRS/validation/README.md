# SSRS RDL Schema-Compatibility Validation

A small, reusable, **schema-aware** structural check for RDL edits. It exists because prose
structural validation can pass an RDL that SSDT later rejects — for example introducing the
2016/01-only `<ReportParametersLayout>` into a 2010/01 RDL.

## Why

RDL elements are gated to schema versions. The schema version is declared by the document's
**root namespace** (`http://schemas.microsoft.com/sqlserver/reporting/<year>/01/reportdefinition`).
An element valid in a newer schema is **invalid** in an older one. Validation must be aware of
the detected version, not just of XML well-formedness.

## How it works

1. **Detect** the schema version from the root namespace (`schemaVersions` in the registry).
2. **Walk** every element in the default RDL namespace.
3. **Compare** each element's minimum version (`elementMinVersion`) against the document's
   version using `versionOrder`.
4. **Fail** if any element requires a newer schema than the document declares.

This is a **version registry**, not a blacklist: the same `<ReportParametersLayout>` passes in
a 2016/01 document and fails in a 2010/01 one. There is no element-specific logic in the code.

## Files

| File | Role |
|------|------|
| `rdl-schema-compatibility.json` | **Single source of truth** — namespace→version map + element→min-version registry. |
| `Validate-RdlSchema.ps1` | The mechanism. Dot-source `Test-RdlSchemaCompatibility`, or run directly with `-Path`. |
| `tests/Run-RdlSchemaTests.ps1` | Regression runner (asserts expected PASS/FAIL per fixture). |
| `tests/fixtures/*.rdl` | Minimal fixtures, incl. the exact reported bug. |

## Run

```powershell
# Validate one RDL (exit 0 = PASS, 1 = FAIL):
powershell -NoProfile -File Validate-RdlSchema.ps1 -Path <file.rdl>

# Run the regression suite:
powershell -NoProfile -File tests/Run-RdlSchemaTests.ps1
```

## Extend

To gate a newly discovered element, add **one entry** to `elementMinVersion` in
`rdl-schema-compatibility.json` (`"ElementLocalName": "<minVersion>"`). No code change needed.
To recognize an additional schema, add its namespace to `schemaVersions` and its label to
`versionOrder`.

## Scope

Structural/schema check only. Preserve the existing schema version during edits unless an
explicit migration is requested (see [`../skills/rdl-minimal-editing.md`](../skills/rdl-minimal-editing.md)).
Visual/render verification remains a developer/SSDT step.
