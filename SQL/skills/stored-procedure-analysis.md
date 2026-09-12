# Skill: stored-procedure-analysis

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** analyzing an existing Stored Procedure referenced by an SSRS dataset or SQL request.

## Purpose

Statically analyze a Stored Procedure definition **strictly read-only** to determine whether a
requested report-specific change can safely be implemented as **report-local inline SQL**
without modifying the Stored Procedure.

---

## Hard Safety Rule: Stored Procedures are Immutable Dependencies

**All Stored Procedures and shared database objects are IMMUTABLE.**

The framework operates under a permanent, non-bypassable guardrail:

### Allowed (Read-Only Analysis & Local Derivation)
- Discover a Stored Procedure and resolve its qualified name (`server.database.schema.proc`).
- Resolve connection profile, engine, active database/catalog context.
- Read its T-SQL/SQL definition from metadata (`sys.sql_modules`, `sys.objects`, `INFORMATION_SCHEMA.ROUTINES`).
- Parse and analyze its parameters, tables, views, joins, filters, expressions, CTEs, and projections.
- Use the discovered logic to generate **report-local inline SQL** for the RDL dataset (when classified as `SAFE_CANDIDATE`).

### Strictly Forbidden (Zero-Tolerance)
- `ALTER PROCEDURE` / `ALTER PROC`
- `CREATE OR ALTER PROCEDURE`
- `CREATE PROCEDURE` / `CREATE PROC`
- `DROP PROCEDURE` / `DROP PROC`
- Any modification, rewrite, or in-place optimization of the shared database procedure.
- Adding columns or business rules to the shared database procedure.
- Modifying any database table, view, function, index, trigger, or schema object.

*There is no workflow path in this framework that permits modifying a Stored Procedure.*

---

## Inspection Scope & Anatomy

When analyzing a procedure definition, inspect all discoverable constructs:

1. **Parameters:** Names, data types, default values, direction (`OUTPUT` vs input).
2. **Referenced Objects:** Base tables, views, user-defined functions, cross-database references.
3. **Joins & Grain:** `INNER JOIN`, `LEFT/RIGHT/FULL OUTER JOIN`, `CROSS JOIN`, join predicates.
4. **Filtering & Logic:** `WHERE` predicates, null handling (`ISNULL`, `COALESCE`), `CASE` expressions.
5. **Grouping & Sorting:** `GROUP BY`, `HAVING`, `ORDER BY`.
6. **Procedural Constructs:**
   - CTEs (`WITH ... AS (...)`)
   - Temporary tables (`#temp`, `##temp`) and Table Variables (`@tableVar`)
   - Window functions (`ROW_NUMBER()`, `RANK()`, `SUM() OVER (...)`)
   - Procedural variables (`DECLARE @var`) and assignments (`SET`, `SELECT @var = ...`)
   - Flow control (`IF...ELSE`, `WHILE`, `GOTO`, `RETURN`)
   - Dynamic SQL (`EXEC(@sql)`, `sp_executesql`)
   - Nested procedure calls (`EXEC procName`)
   - Multi-statement DML (`INSERT`, `UPDATE`, `DELETE`, `MERGE`, `TRUNCATE`)
   - Multiple `SELECT` result sets
7. **Final Projection:** Final output column list, data types, aliases, calculated expressions.

---

## Static Classification & Complexity Framework

Stored Procedures are classified along two dimensions: **Risk/Complexity Tier** and **Conversion Decision**.

### Complexity / Risk Tiers

- **LOW Risk:**
  - Simple `SELECT` statement
  - Straightforward joins and simple `WHERE` filters
  - Deterministic calculated columns
  - No temporary table pipeline, no dynamic SQL
  - Single/few result paths
  - **Preferred Path:** `REPORT_LOCAL_SQL` (when conversion is approved/required)

- **MEDIUM Risk:**
  - CTEs (`WITH ... AS (...)`)
  - Procedural variables and assignments
  - Multiple joins with parameter-dependent branches
  - Limited temporary tables (`#temp`) or table variables
  - Window functions (`ROW_NUMBER()`, `RANK()`)
  - **Preferred Path:** `REPORT_LOCAL_SQL` with careful verification, or `REPORT_SCOPED_QUERY`

- **HIGH Risk:**
  - Heavy temporary table pipelines (multiple `#temp` tables)
  - Explicit temp-table indexes (`CREATE CLUSTERED/NONCLUSTERED INDEX`)
  - Multi-stage intermediate materialization
  - Multi-database queries across several catalogs/schemas
  - Complex `XML PATH('')` / `STUFF` string aggregations or deep JSON parsing
  - Dynamic SQL (`sp_executesql`, `EXEC(@sql)`)
  - Nested stored procedure calls (`EXEC procName`)
  - Multiple result sets or procedural flow control (`IF...ELSE`, cursors)
  - **Preferred Path:** **`REPORT_SCOPED_QUERY`** (design a clean, minimal report-specific query containing only the tables, joins, filters, and fields actually required by the target report) rather than blindly flattening the full procedure. If safe scope cannot be established, stop with `REVIEW_REQUIRED`.

---

## Three Safe Execution Modes

After discovery and complexity analysis, determine the execution mode:

### 1. `KEEP_SP`
Use the existing Stored Procedure without altering it when the requested report change can be achieved without modifying SQL logic (e.g. formatting, grouping, parameter prompts, report-level expressions, or visibility toggles).

### 2. `REPORT_LOCAL_SQL`
Convert the Stored Procedure logic into a self-contained report-local inline SQL statement (`CommandType = Text`) with CTEs **only** when the procedure is classified as `LOW` or `MEDIUM` complexity, is safely reproducible, and performance/semantic risk is acceptable.

### 3. `REPORT_SCOPED_QUERY`
Instead of flattening an entire complex or `HIGH`-risk Stored Procedure (e.g. 12 temporary tables, indexing, multi-scan materialization), design a smaller, dedicated, report-specific query using **only** the tables, joins, filters, calculations, and columns actually required by the target report.
- **Preferred alternative for HIGH-risk procedures:** Avoids reproducing large, irrelevant materialization pipelines inside an SSRS dataset query.
- Preserves exact parameter semantics and verified output contracts.
- Leaves the shared Stored Procedure 100% untouched.

---

## Decision Statuses & Fail-Closed Model

Every Stored Procedure analysis must output one of the four decision statuses:

```text
SP_ANALYSIS_STATUS = SAFE_CANDIDATE | REVIEW_REQUIRED | DO_NOT_AUTO_CONVERT
```

### 1. `KEEP_SP`
The existing Stored Procedure is kept as the dataset command when the requested report change can be achieved without modifying SQL logic (e.g. formatting, grouping, parameter prompts, report expressions, visibility).

### 2. `REPORT_LOCAL_SQL`
Candidate only when the Stored Procedure is `LOW` or `MEDIUM` complexity, safely representable as report-local SQL, and the required business logic is authoritative and fully resolvable.

### 3. `REPORT_SCOPED_QUERY`
Preferred alternative for `HIGH`-risk Stored Procedures (e.g. multi-temp-table pipelines, indexed materialization, multi-DB queries) where the report requires only a controlled subset of the procedure's business logic.

### 4. `DO_NOT_AUTO_CONVERT` / `REVIEW_REQUIRED` (Fail-Closed Engine)
The framework **MUST NEVER** automatically convert when any of the following blocking conditions are detected:
1. Dynamic SQL (`sp_executesql`, `EXEC(@sql)`).
2. Nested `EXEC` procedure dependencies exist and cannot be resolved.
3. Multiple `SELECT` result sets exist.
4. External procedure/function dependencies are unresolved or inaccessible.
5. Required business logic is unresolved.
6. Authoritative source for a requested column/field is unknown or ambiguous.
7. Temp-table materialization is too complex to safely preserve without performance degradation.
8. Complex `XML PATH('')`/`STUFF` or deep JSON parsing behavior cannot be preserved confidently.
9. Output contract cannot be verified 100% against the original procedure.
10. Parameter mapping (1:1) cannot be verified.
11. Query semantics, join cardinalities, or grouping grain are ambiguous.
12. Performance characteristics cannot be reasonably preserved.
13. Conversion would require guessing, fabricating, or assuming business rules.

*When uncertain on any technical or business condition, the framework must **FAIL CLOSED** and return `REVIEW_REQUIRED`.*

---

## Controlled Reference Logic Discovery Workflow (`REFERENCE_LOGIC_DISCOVERY`)

When a requested field or business concept (e.g. `BuildDate`, `Receivables`, `OutstandingDays`, `ReviewDate`) cannot be resolved directly from the procedure's immediate projection or referenced schema, follow the progressive discovery order before asking the developer:

### Progressive Discovery Precedence:
1. **Target RDL:** Dataset `<Query>`, `<Fields>`, expressions (`=Fields!...`, `=Parameters!...`, `=Code....`), report items, filters.
2. **Stored Procedure Definition:** Comments, inactive branches, intermediate expressions, source logic.
3. **Referenced Views / Functions:** Underlying view definitions and UDF schemas.
4. **Referenced Tables / Columns:** Base schema columns in the active database.
5. **Existing SSRS RDLs in Workspace:** Other reports in `projectRoot` or solution defining the concept.
6. **Existing SQL Scripts in Workspace:** Approved SQL definitions and migration scripts in the workspace.
7. **Framework Reference-Logic Artifacts:** Templates and model documentation.

### Candidate Logic Recording:
For every discovered candidate definition, record:
- **Concept name:** Exact requested business concept.
- **Source file/object/report:** Path or qualified object name.
- **Source type:** RDL Expression, View, Stored Procedure, Table Column, or SQL Script.
- **Exact expression/logic location:** Verbatim expression or SQL fragment.
- **Required tables/columns:** Dependencies needed to compute the concept.
- **Required parameters:** Parameter bindings required.
- **Confidence & Status:** `AUTHORITATIVE`, `EQUIVALENT`, or `SIMILAR_NON_AUTHORITATIVE`.

### Strict Guardrail: Similar Columns Are Never Automatically Authoritative
- A similarly named column (e.g. `CreatedDate`, `BilledDate`, `ReceivedDate` when `BuildDate` is requested) is **SIMILAR_NON_AUTHORITATIVE**.
- The framework **MUST NOT** automatically select or substitute a similar column.
- If authoritative logic is discovered in an existing report, present it to the developer for explicit confirmation:
  > *"Existing logic found: Source: `<report/object>`, Concept: `<concept>`, Logic: `<summary>`, Dependencies: `<deps>`. Use this existing logic for the target report?"*
- If no authoritative logic exists anywhere across the 7 discovery levels:
  > *" `<Concept>` could not be resolved from authoritative sources. Please provide the source table/column or business calculation."* (Do not ask the developer to rewrite the entire query).

---

## Report-Local SQL Provenance Record

Whenever `REPORT_LOCAL_SQL` or `REPORT_SCOPED_QUERY` is selected, produce a structured provenance record:

```text
==================================================
REPORT-LOCAL SQL PROVENANCE RECORD
==================================================
Original Stored Procedure : <schema.procedureName>
Target Report             : <path/reportName.rdl>
Target Dataset            : <datasetName>
Selected Execution Mode   : KEEP_SP | REPORT_LOCAL_SQL | REPORT_SCOPED_QUERY
Reason for Conversion     : <explicit business change requested>
Risk Classification       : LOW | MEDIUM | HIGH
Authoritative Logic Sources: <discovered authoritative source, RDL, or developer definition>
Parameter Mappings (1:1)  :
  - SSRS Parameter        : @ParamName
    SP Parameter          : @ParamName
    Local SQL Parameter   : @ParamName
Original Output Contract  : <list of all original output columns with aliases>
Resulting Output Contract : <list of resulting output columns + newly added fields>
Conversion Limitations    : <performance considerations, flattening boundaries, or None>
Assumptions Recorded      : <explicitly stated assumptions, or None>
Unresolved Dependencies   : <explicitly stated gaps, or None>
Shared SP Safety Status   : CONFIRMED UNTOUCHED (Zero DDL/DML executed or generated)
Developer Approval Status : PENDING_CONFIRMATION | APPROVED
==================================================
```

---

## Output & Parameter Contract Verification

Before allowing any conversion candidate to proceed:
1. **1:1 Parameter Mapping:**
   - Parameter names, data types, defaults, and directions match across SSRS Report Parameters, Stored Procedure Parameters, and Local SQL Query Parameters.
2. **Output Contract Preservation:**
   - All expected output columns and aliases are preserved.
   - Data types and nullability are preserved where statically determinable.
   - Required calculated fields, window functions, and `CASE` rules are preserved.
   - No unexpected output column losses or accidental additions.
   - `XML PATH('')`/`STUFF` string aggregations and `JSON_VALUE` parsing paths are preserved verbatim.
   - Filters, parameter logic, and grouping grains remain intact.
3. **Deterministic Mismatch Action:** Any parameter or output contract mismatch halts automatic conversion with `REVIEW_REQUIRED`.

---

## Known Limitations

1. **Dynamic SQL Inlining:** Dynamic SQL (`sp_executesql`) cannot be represented as static report-local inline SQL and remains strictly blocked (`DO_NOT_AUTO_CONVERT`).
2. **External Linked Server Dependencies:** Dependencies spanning linked servers or unconfigured network boundaries outside the Active Data Source Context are blocked.
3. **Procedural Looping:** Procedures utilizing cursors or multi-step iterative loops to build output must be re-architected or designed via `REPORT_SCOPED_QUERY` with developer review.

---

## Minimum-Credit / Progressive Discovery Execution

To optimize token and execution credits:
- **Level 1 (Target Scope):** Inspect target RDL + referenced Stored Procedure only.
- **Level 2 (Workspace Scope):** Only if the concept remains unresolved, search relevant workspace reports and SQL scripts.
- **Level 3 (Broader Scope):** Broader reference catalog search only if still unresolved.
- Never perform a brute-force workspace dump. Never invoke database inspection if the logic is already determinable from local project files. Omit full validation for simple non-structural tasks.

---

## Framework Decision Tree

```text
SSRS change requested
        |
        v
Does target dataset use inline SQL?
        |
     YES --> Modify existing query safely
        |
       NO
        |
        v
Stored Procedure?
        |
       YES
        |
        v
Can requested change be achieved without changing SP?
        |
     YES --> KEEP_SP
        |
       NO
        |
        v
Discover authoritative reference logic (REFERENCE_LOGIC_DISCOVERY)
        |
        +--> Found authoritative logic --> Request developer confirmation
        |
        +--> Not found --> Request ONLY the missing business definition
        |
        v
Classify SP complexity & risk
        |
        +--> LOW/MEDIUM risk + safely reproducible
        |          --> REPORT_LOCAL_SQL
        |
        +--> HIGH risk (multi-temp tables / indexing / multi-DB)
                   --> REPORT_SCOPED_QUERY (design minimal report-scoped query)
                       if safe scope can be established
                   --> otherwise STOP & report REVIEW_REQUIRED
```

---

## Decision Output Format

Produce the structured diagnostic receipt:

```text
SP_ANALYSIS_STATUS = SAFE_CANDIDATE | REVIEW_REQUIRED | DO_NOT_AUTO_CONVERT

Procedure details:
- Procedure: <schema.procedureName>
- DataSource: <DataSourceReference>
- Server: <physical/logical server>
- Database: <database>
- Schema: <schema>

Analysis findings:
- Complexity Risk Tier: LOW | MEDIUM | HIGH
- Execution Mode Selected: KEEP_SP | REPORT_LOCAL_SQL | REPORT_SCOPED_QUERY
- Parameters: <list of parameters with types>
- Referenced objects: <tables, views, functions>
- Procedural constructs: <none | CTEs | temp tables | dynamic SQL | DML | etc.>
- Output columns: <list of projected columns>
- Complexity findings: <specific structural observations>

Reference Logic Discovery:
- Concept Name: <concept>
- Discovery Status: FOUND_AUTHORITATIVE | SIMILAR_NON_AUTHORITATIVE | NOT_FOUND
- Candidate Source: <source or None>

Decision:
- Requested change compatibility: <COMPATIBLE | BLOCKED | AMBIGUOUS>
- Recommended implementation path: <KEEP_SP | REPORT_LOCAL_SQL | REPORT_SCOPED_QUERY | Developer Review | Blocked>
- Blocking reason (if any): <None | Reason>
```

---

## Cost Optimization & Token Efficiency

- Perform stored procedure extraction and analysis **only** when a stored procedure dataset is targeted.
- Do not re-read or dump the entire RDL when analyzing a procedure dataset.
- Use targeted SQL metadata queries (`sys.sql_modules`, `sys.objects`) scoped to the procedure name.
- Do not invoke the full RDL validation pipeline until the final report-local RDL modification is actually made.
