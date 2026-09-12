# Skill: report-discovery

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** the target `.rdl` must be located before any edit.

## Purpose

Find the correct `.rdl` under the configured `projectRoot` without guessing.

## Steps

1. Read `SSRS/workspace.config.json`; use `projectRoot` (never ask again if set). Stop if
   the config is missing, `projectRoot` is unavailable, or it does not contain the local
   `.sln`/`.rptproj`.
2. Treat the resolved `.sln`/`.rptproj` as the authoritative local project boundary. Use
   its project root as the source-discovery root. First enumerate matching `.rdl` files
   physically under that root, then remove paths under build/output/generated artifact
   directories such as `bin`, `obj`, `Debug`, `Release`, `build`, `out`, or `publish`.
   Inspect `.rptproj` membership as preferred evidence and use it to prefer a matching
   included source RDL when candidates otherwise tie, but never use missing membership as
   an exclusion predicate. A matching RDL in the project source root is the **only**
   modification target; an artifact copy never competes as a local candidate.
3. Match the user-provided report name/path against the complete filtered RDL candidate set;
   the resolver must not contain a report-specific filename, folder, or test-case exception.
   Ignore `*.spec.md` and other specification/documentation files as modification targets. A
   deployed SSRS Catalog may be consulted only as read-only evidence for discovery,
   deployed-path verification, report-reference analysis, Stored Procedure analysis, or
   business-logic evidence; it never supplies or replaces the local modification target.
4. After artifact and documentation filtering, if **one** genuine source RDL remains, lock it
   and proceed regardless of whether its `.rptproj` item exists. If **several** genuine source
   RDL candidates remain, list their paths and **ask the user to choose**; do not guess.
   If no matching local RDL exists, stop and ask for the correct local RDL/Project, even if
   the report exists in the Catalog. Do not modify or overwrite the Catalog artifact.
5. Confirm the locked `.rdl` exists inside the resolved project source root and is not under
   an excluded artifact directory before handing it to analysis, editing, or any SSRS-to-SQL
   handoff. Project membership may support precedence and validation but is not, by itself,
   a prerequisite for a source RDL to be eligible.

## Output

The absolute path of the confirmed target `.rdl` (inside `projectRoot`).

Scope and secrets: [`security.md`](../../instructions/security.md).
