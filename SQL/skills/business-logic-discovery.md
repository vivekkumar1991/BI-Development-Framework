# Skill: business-logic-discovery

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** mode is REFERENCE_LOGIC, REFERENCE_LOGIC_DISCOVERY, or READ_ONLY stored procedure analysis.

## Purpose

Find where an existing, approved business rule or field definition exists across authoritative
sources and reuse it — **never invent**.

## Controlled Progressive Reference Logic Discovery (Precedence Order)

When a requested business field/concept (e.g. `BuildDate`, `Receivables`, `OutstandingDays`, `ReviewDate`) cannot be resolved directly from the target dataset query, discover authoritative logic following this strict 7-level precedence:

1. **Target RDL:** Dataset `<Query>`, `<Fields>`, report expressions (`=Fields!...`, `=Parameters!...`, `=Code....`), filters, and item calculations.
2. **Stored Procedure Definition:** Comments, inactive branches, intermediate expressions, source logic of the referenced proc.
3. **Referenced Views / Functions:** Underlying view definitions and UDF schemas in the active database context.
4. **Referenced Tables / Columns:** Base schema columns in the active database.
5. **Existing SSRS RDLs in Workspace:** Other reports in `projectRoot` or solution defining the concept.
6. **Existing SQL Scripts in Workspace:** Approved SQL definitions and migration scripts in the workspace.
7. **Framework Reference-Logic Artifacts:** Templates and model documentation.

## Strict Rule: Similar Column Names are NEVER Automatically Authoritative

When searching schema for a requested concept:
- Example: Requested `BuildDate` vs Available `CreatedDate`, `BilledDate`, `ReceivedDate`.
- The framework **MUST NOT** automatically choose, substitute, or guess a similarly named column.
- It is classified as `SIMILAR_NON_AUTHORITATIVE`.
- If an existing report or script contains an explicit, authoritative calculation or mapping, record it as an authoritative candidate and present it to the developer for explicit confirmation:
  > *"Existing logic found: Source: `<report/object>`, Concept: `<concept>`, Logic: `<summary>`, Dependencies: `<dependencies>`. Use this existing logic for the target report?"*
- If no authoritative definition exists anywhere across the 7 levels, ask the developer **only** for the missing business definition (do not ask them to write the full SQL query):
  > *" `<Concept>` could not be resolved from authoritative sources. Please provide the source table/column or business calculation."*

## Output

Return a Concept Evidence Contract for [`sql-generation`](sql-generation.md), paired with
[`report-reference-analysis`](report-reference-analysis.md):

```
Business concept       : <requested concept/name>
Evidence status        : <DIRECTLY_REUSABLE | DEPENDENCY_MAPPING_REQUIRED | CONFLICTING_DEFINITIONS | INSUFFICIENT_EVIDENCE>
Authoritative source   : <current report/RDL or established same-context source, when available>
Report / dataset       : <report name/path | dataset>
SQL / procedure source : <query text reference | schema.procedure>
Calculation/expression : <verbatim definition, when present>
Filters / parameters   : <verbatim logic and parameter semantics>
Tables/views           : <qualified references>
Dependencies           : <procedures | functions | other objects>
Output columns         : <column/expression | alias | order, when available>
Definition evidence    : <RDL/Catalog record identity + Active Data Source Context>
Evidence gaps/conflicts: <missing or differing definitions>
```

- **DIRECTLY_REUSABLE** — one consistent, fully evidenced definition with no unresolved
   dependency mapping.
- **DEPENDENCY_MAPPING_REQUIRED** — logic is evidenced, but parameters, objects, fields, or
   dependencies must be mapped before it can be used in report-local SQL.
- **CONFLICTING_DEFINITIONS** — multiple same-context sources define the concept differently;
   present each source and ask the user unless authoritative evidence resolves the conflict.
- **INSUFFICIENT_EVIDENCE** — no complete, consistent definition was found; ask the user rather
   than inferring it.

When the selected source is a Stored Procedure, invoke the existing
`STORED_PROCEDURE_ANALYSIS` contract as read-only evidence and include its extracted logic and
dependencies. Do not modify the procedure. A `DIRECTLY_REUSABLE` or
`DEPENDENCY_MAPPING_REQUIRED` contract may become SQL-generation input only after required
mapping/clarification; it does not modify an RDL by itself.

## Stored Procedure Analysis Contract

For `STORED_PROCEDURE_ANALYSIS`, read the original procedure only. Preserve its source and
semantics exactly: do not execute write operations, optimize, rewrite, alter, create, drop, or
convert it to inline SQL. Produce the following contract from supplied source or targeted
read-only inspection evidence; mark unavailable facts as `not discoverable` rather than
inventing them.

```
Procedure             : <schema.procedure>
Active context        : <logical source | engine | endpoint | database/catalog | schema>
Input parameters      : <name | type | default behavior, when discoverable>
Referenced tables/views: <qualified objects>
Joins                 : <join type | objects | exact conditions>
Filters               : <WHERE/HAVING logic>
CTEs                  : <names | definitions | dependencies>
Temporary state       : <temporary tables | table variables>
Variables/calculations: <variables | assignments | intermediate calculations>
Business rules        : <CASE and other decision logic, verbatim>
Aggregations/grouping : <aggregate expressions | GROUP BY>
Final result sets     : <one entry per final SELECT/result set>
Output columns        : <column/expression | alias | order, when discoverable>
Dependencies          : <procedures | functions | other objects>
Dynamic SQL           : <present/absent | source/execution behavior>
External dependencies : <linked server | cross-server/database/source references>
Conversion class      : <SAFE_CANDIDATE | REVIEW_REQUIRED | DO_NOT_AUTO_CONVERT>
Evidence gaps         : <unavailable source/metadata or ambiguity>
```

Classify only from observed evidence:

- **SAFE_CANDIDATE** — a simple, single-result `SELECT` with no dynamic SQL, nested procedure
   execution, multiple result sets, external dependency, side effect, or unreviewed semantic
   complexity.
- **REVIEW_REQUIRED** — CTEs, variables, temporary tables/table variables, conditional logic,
   multiple dependencies, or other logic whose semantic equivalence requires review.
- **DO_NOT_AUTO_CONVERT** — dynamic SQL, nested procedure execution, multiple result sets,
   external/cross-server dependencies, side effects, or any case where safe inline equivalence
   cannot be established.

If the procedure or any dependency lies outside the locked Active Data Source Context, flag it
as an external dependency, set `DO_NOT_AUTO_CONVERT`, and block cross-context inspection or
reuse pending user clarification. The contract never modifies the procedure. It can be consumed
only by an approved `SP_TO_INLINE` workflow when the class is `SAFE_CANDIDATE`.
