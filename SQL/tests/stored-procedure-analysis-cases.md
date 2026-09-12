# SQL Stored Procedure Static Analysis Regression Cases

These static regression cases validate the stored procedure static analysis, classification, and
safe report-local inline SQL decisioning rules without modifying any real RDL, .rptproj, Stored
Procedure, database object, or production system.

---

## Case 1: Simple SELECT Stored Procedure

**Scenario:** Procedure executes a single `SELECT` statement with basic filters and no procedural constructs.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_GetActiveRegions
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        RegionId,
        RegionName,
        IsActive
    FROM dbo.Regions
    WHERE IsActive = 1
    ORDER BY RegionName;
END;
```

**Evaluation:**
- Parameters: None.
- Referenced Objects: `dbo.Regions` (single table).
- Procedural Constructs: None (single SELECT).
- Dynamic SQL / DML / Nested Procs: None.
- Result Sets: Exactly 1.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = SAFE_CANDIDATE
Recommended implementation path: Report-Local Inline SQL
```

---

## Case 2: SELECT with Multi-Table Joins, Expressions, and Parameters

**Scenario:** Procedure takes input parameters, joins multiple tables, uses `CASE` expressions and `ISNULL`, and returns a single projection.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_CustomerSummary
    @StartDate DATETIME,
    @EndDate DATETIME,
    @TerritoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CustomerID,
        c.AccountNumber,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        t.Name AS TerritoryName,
        ISNULL(SUM(soh.TotalDue), 0) AS TotalSales,
        CASE WHEN c.PersonID IS NOT NULL THEN 'Individual' ELSE 'Store' END AS CustomerType
    FROM sales.Customer c
    INNER JOIN sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
    LEFT JOIN person.Person p ON c.PersonID = p.BusinessEntityID
    LEFT JOIN sales.SalesOrderHeader soh
        ON c.CustomerID = soh.CustomerID
        AND soh.OrderDate >= @StartDate
        AND soh.OrderDate <= @EndDate
    WHERE (@TerritoryID IS NULL OR c.TerritoryID = @TerritoryID)
    GROUP BY
        c.CustomerID,
        c.AccountNumber,
        p.FirstName,
        p.LastName,
        t.Name,
        c.PersonID;
END;
```

**Evaluation:**
- Parameters: `@StartDate`, `@EndDate`, `@TerritoryID`.
- Referenced Objects: `sales.Customer`, `sales.SalesTerritory`, `person.Person`, `sales.SalesOrderHeader`.
- Joins: `INNER JOIN`, `LEFT JOIN` (well-defined relational joins).
- Procedural Constructs: None (single grouped SELECT).
- Dynamic SQL / DML / Nested Procs: None.
- Result Sets: Exactly 1.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = SAFE_CANDIDATE
Recommended implementation path: Report-Local Inline SQL
```

---

## Case 3: Complex Temp-Table & Multi-Stage Stored Procedure (HIGH Risk)

**Scenario:** Procedure creates multiple temporary tables with explicit index creations (`CREATE CLUSTERED/NONCLUSTERED INDEX`) and multi-stage intermediate materialization across large tables.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_ComplexPipeline
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT wo.WOID, wo.ProdLineID, wo.BilledDate
    INTO #BaseWOIDs
    FROM OSI.dbo.WorkOrders wo WITH (NOLOCK)
    WHERE wo.BilledDate BETWEEN @StartDate AND @EndDate;

    CREATE CLUSTERED INDEX IX_Base ON #BaseWOIDs(WOID);

    SELECT bw.WOID, COUNT(*) AS DocCount
    INTO #DocSummary
    FROM Docrepository..Documents d WITH (NOLOCK)
    INNER JOIN #BaseWOIDs bw ON d.PrimaryIndex = bw.WOID
    GROUP BY bw.WOID;

    CREATE CLUSTERED INDEX IX_Doc ON #DocSummary(WOID);

    SELECT bw.WOID, bw.BilledDate, ISNULL(ds.DocCount, 0) AS DocCount
    FROM #BaseWOIDs bw
    LEFT JOIN #DocSummary ds ON bw.WOID = ds.WOID;
END;
```

**Evaluation:**
- Complexity Tier: `HIGH` (Multiple `#temp` tables, explicit index creation, multi-database queries).
- Invariant: Framework **MUST NOT blindly flatten** this 12-table materialization pipeline into unmaterialized CTEs.
- Action: Proposes `REPORT_SCOPED_QUERY` if specific report scope is provided; otherwise stops with `REVIEW_REQUIRED`.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = REVIEW_REQUIRED
Complexity Tier: HIGH
Recommended implementation path: REPORT_SCOPED_QUERY (or Developer Review)
```

---

## Case 4: Dynamic SQL Procedure (`sp_executesql` / `EXEC`)

**Scenario:** Procedure constructs SQL string dynamically based on optional filters and executes via `sp_executesql`.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_DynamicSearch
    @SearchColumn VARCHAR(50),
    @SearchValue VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT OrderID, CustomerID, OrderDate FROM sales.Orders WHERE '
               + QUOTENAME(@SearchColumn) + N' = @val';
    EXEC sp_executesql @sql, N'@val VARCHAR(100)', @val = @SearchValue;
END;
```

**Evaluation:**
- Procedural Constructs: Dynamic SQL generation, `sp_executesql` invocation.
- Risk: Cannot be represented as a static inline SQL statement in RDL without knowing runtime column parameters; high injection and translation risk.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = DO_NOT_AUTO_CONVERT
Blocking reason: Dynamic SQL execution (sp_executesql) cannot be deterministically translated into static report-local SQL.
Recommended implementation path: Blocked
```

---

## Case 5: Nested Procedure Execution (`EXEC procName`)

**Scenario:** Procedure executes a downstream stored procedure to retrieve or stage data.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_ConsolidatedFinancials
    @PeriodId INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.usp_CalculatePeriodAccruals @PeriodId = @PeriodId;

    SELECT
        AccountCode,
        Debit,
        Credit
    FROM fin.GeneralLedger
    WHERE PeriodId = @PeriodId;
END;
```

**Evaluation:**
- Procedural Constructs: Nested procedure call `EXEC dbo.usp_CalculatePeriodAccruals`.
- Risk: Side-effect or state-mutation in downstream procedure cannot be encapsulated in a pure `SELECT` query.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = DO_NOT_AUTO_CONVERT
Blocking reason: Nested stored procedure call 'usp_CalculatePeriodAccruals' contains external execution dependencies that cannot be flattened into a report-local query.
Recommended implementation path: Blocked
```

---

## Case 6: Procedure Containing DML / Side Effects (`INSERT`/`UPDATE`/`DELETE`)

**Scenario:** Procedure logs audit information or updates tracking tables prior to returning data.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_ExportInvoices
    @BatchId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE billing.InvoiceBatch
    SET LastExportDate = GETUTCDATE(), ExportCount = ExportCount + 1
    WHERE BatchId = @BatchId;

    SELECT
        InvoiceNumber,
        InvoiceDate,
        TotalAmount
    FROM billing.Invoices
    WHERE BatchId = @BatchId;
END;
```

**Evaluation:**
- Procedural Constructs: `UPDATE billing.InvoiceBatch` (data-modifying DML statement).
- Risk: SSRS dataset inline SQL queries must be pure read-only `SELECT` statements. DML side effects cannot and must not be included.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = DO_NOT_AUTO_CONVERT
Blocking reason: Procedure contains DML write operations (UPDATE) which violate read-only safety rules and cannot be converted to report-local SQL.
Recommended implementation path: Blocked
```

---

## Case 7: Existing Authoritative Business Logic Discovered in Another Report

**Scenario:** Requested concept `OutstandingDays` is missing from the target procedure schema, but `REFERENCE_LOGIC_DISCOVERY` finds an exact definition in `ReceivablesSummary.rdl`: `DATEDIFF(day, soh.OrderDate, GETDATE())`.

**Evaluation:**
- Discovery Precedence: Level 5 (Workspace RDLs).
- Confidence: `AUTHORITATIVE`.
- Action: Candidate logic recorded and presented to developer for explicit confirmation before use.

**Expected Output:**
```text
Candidate Logic Discovered:
- Concept: OutstandingDays
- Source: ReceivablesSummary.rdl (DataSet: MainSales)
- Logic: DATEDIFF(day, soh.OrderDate, GETDATE())
- Status: AUTHORITATIVE
Prompt to Developer: "Existing logic found in ReceivablesSummary.rdl. Use this existing logic for the target report?"
```

---

## Case 8: Similar but Non-Authoritative Column Found (`BuildDate` vs `CreatedDate`)

**Scenario:** User requests: *"Add BuildDate to this report"*. Schema discovery finds `CreatedDate`, `BilledDate`, and `ReceivedDate` on `WorkOrders`.

**Evaluation:**
- Confidence: `SIMILAR_NON_AUTHORITATIVE`.
- Invariant: Framework **MUST NOT** substitute `CreatedDate` or `BilledDate` for `BuildDate`.
- Action: Halts with `REVIEW_REQUIRED` and asks developer *only* for the missing `BuildDate` definition without asking to rewrite SQL.

**Expected Output:**
```text
SP_ANALYSIS_STATUS = REVIEW_REQUIRED
Issue: BuildDate could not be resolved from authoritative sources.
Action: Stopped. Prompted developer: "BuildDate could not be resolved from authoritative sources. Please provide the source table/column or business calculation."
```

---

## Case 9: Zero Modification of Shared Stored Procedure

**Scenario:** Verification that no generated workflow contains `ALTER PROCEDURE`, `CREATE OR ALTER PROCEDURE`, `CREATE PROCEDURE`, or `DROP PROCEDURE`.

**Evaluation:**
- Invariant: Stored Procedures are strictly immutable dependencies.
- Static Check: All SQL Agent skill rules and validation checks explicitly reject DDL against procedures with a `[BLOCKER]`.

**Expected Output:**
```text
PASSED: Zero DDL operations against stored procedures permitted by the framework.
```

---

## Case 10: Parameter and Output Contract Preservation (REPORT_LOCAL_SQL / REPORT_SCOPED_QUERY)

**Scenario:** An approved report-local SQL query is verified for 1:1 parameter mapping and output column preservation before RDL modification.

**Evaluation:**
- 1:1 Parameter Mapping: `@StartDate`, `@EndDate`, `@TerritoryID` preserved.
- Output Contract: `CustomerID`, `AccountNumber`, `CustomerName`, `TerritoryName`, `TotalSales`, `CustomerType` preserved with exact aliases.
- Data types, aggregations, and NULL handling preserved.
- Shared Procedure: 100% untouched.

**Expected Output:**
```text
==================================================
REPORT-LOCAL SQL PROVENANCE RECORD
==================================================
Original Stored Procedure : dbo.usp_rpt_CustomerSummary
Target Report             : CustomerSummary.rdl
Target Dataset            : Main
Selected Execution Mode   : REPORT_LOCAL_SQL
Risk Classification       : LOW
Parameter Mappings (1:1)  : Verified (@StartDate, @EndDate, @TerritoryID)
Output Columns Preserved  : Verified (6/6 columns preserved)
Shared SP Safety Status   : CONFIRMED UNTOUCHED (Zero DDL/DML executed or generated)
==================================================
PASSED: Contract validation succeeds.
```

---

## Case 11: Missing Authoritative Column Definition (`BuildDate`)

**Scenario:** Requested field `BuildDate` is completely absent across all 7 discovery levels (Target RDL, Procedure Definition, Views, Tables, Workspace RDLs, Workspace SQL, Documentation).

**Evaluation:**
- Discovery Precedence: Level 1 through 7 executed.
- Result: Not found in any authoritative source.
- Invariant: Framework must not fabricate or guess a formula.
- Action: Fail-closed to `REVIEW_REQUIRED` and ask developer *only* for the missing definition.

**Expected Output:**
```text
SP_ANALYSIS_STATUS = REVIEW_REQUIRED
Issue: BuildDate could not be resolved from authoritative sources.
Action: Stopped. Prompted developer: "BuildDate could not be resolved from authoritative sources. Please provide the source table/column or business calculation."
```

---

## Case 12: Stored Procedure with Multiple Result Sets

**Scenario:** Procedure returns multiple distinct `SELECT` results to the caller (e.g., summary header + line items).

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_MultiResultReport
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result Set 1
    SELECT OrderID, OrderDate, TotalDue FROM sales.Orders WHERE OrderID = @OrderId;
    -- Result Set 2
    SELECT ItemID, OrderID, Quantity, UnitPrice FROM sales.OrderItems WHERE OrderID = @OrderId;
END;
```

**Evaluation:**
- Procedural Constructs: Multiple `SELECT` result sets.
- Risk: An SSRS dataset expecting a single tabular result cannot bind multiple result sets from a single inline SQL command.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = DO_NOT_AUTO_CONVERT
Blocking reason: Procedure returns multiple result sets, which cannot be represented as a single report-local dataset query.
Recommended implementation path: Blocked
```

---

## Case 13: Unresolved External Linked-Server Dependency

**Scenario:** Procedure accesses data via an unconfigured remote linked server.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_RemoteInventory
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, Quantity
    FROM [REMOTE_SRV_02].[WarehouseDB].[dbo].[Stock];
END;
```

**Evaluation:**
- External Dependencies: Remote linked server `REMOTE_SRV_02` outside the locked Active Data Source Context.
- Risk: Cross-server boundaries cannot be safely validated in developer-local scope.

**Expected Classification:**
```text
SP_ANALYSIS_STATUS = DO_NOT_AUTO_CONVERT
Blocking reason: Procedure references external linked server 'REMOTE_SRV_02' outside the Active Data Source Context.
Recommended implementation path: Blocked
```

---

## Case 14: Complex XML/STUFF / Deep JSON Preservation Risk

**Scenario:** Procedure contains complex `FOR XML PATH('')` / `STUFF` string aggregations and `JSON_VALUE` extractions with nested subqueries whose semantic equivalence cannot be deterministically proven during flattening.

**Fixture:**

```sql
CREATE PROCEDURE dbo.usp_rpt_ComplexJsonXml
    @WOID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        wo.WOID,
        STUFF((SELECT ',' + dd.DocKey
               FROM Docs dd
               WHERE dd.WOID = wo.WOID
               FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(MAX)'), 1, 1, '') AS DocKeys,
        JSON_VALUE(wo.RawJson, '$.attributes[0].nested.property') AS NestedProp
    FROM WorkOrders wo
    WHERE wo.WOID = @WOID;
END;
```

**Evaluation:**
- Complexity Tier: `HIGH` (XML Path evaluation, JSON parsing).
- Invariant: If flattening or inlining carries risk of altering XML node escaping, collation, or null handling, do not force automatic conversion.
- Action: Flag preservation risk and require explicit developer review (`REVIEW_REQUIRED`).

**Expected Output:**
```text
SP_ANALYSIS_STATUS = REVIEW_REQUIRED
Complexity findings: Contains XML/STUFF and JSON parsing requiring verified preservation.
Recommended implementation path: Developer Review
```

---

## Case 15: Unexpected RDL Diff Scope Blocked (Diff Guard)

**Scenario:** An RDL edit for dataset inline SQL conversion inadvertently modifies unrelated tablix columns, page margins, or another dataset.

**Evaluation:**
- Diff Guard: Compares expected diff scope (`<DataSet>` query and fields) against actual diff.
- Invariant: Unrelated changes outside dataset query/fields are strictly rejected.
- Action: Blocked $\rightarrow$ `REVIEW_REQUIRED`.

**Expected Output:**
```text
DIFF_GUARD_STATUS = FAIL (REVIEW_REQUIRED)
Issue: Unexpected diff detected outside target dataset scope (unrelated layout/page nodes modified).
Action: RDL modification rejected.
```

---

## Case 16: Schema-Version Incompatibility (2010/01 with 2016 Parameter Layout)

**Scenario:** A 2010/01 schema RDL has `<ReportParametersLayout>` injected into it.

**Evaluation:**
- Schema: `2010/01` (does not support parameter panel layout metadata).
- Action: Schema upgrade prohibited; layout node stripped or rejected $\rightarrow$ `PREFLIGHT_STATUS = FAIL`.

**Expected Output:**
```text
PREFLIGHT_STATUS = FAIL
Category: RDL Structural
Issue: Element 'ReportParametersLayout' is invalid for RDL schema '2010/01'.
```

---

## Case 17: Valid 2010/01 Schema RDL (No Layout Node)

**Scenario:** Standard 2010/01 schema RDL with defined parameters and no `<ReportParametersLayout>` node.

**Evaluation:**
- Schema: `2010/01`.
- Defined parameters valid, layout node absent (correct per schema).
- Pre-flight validation passes.

**Expected Output:**
```text
PREFLIGHT_STATUS = PASS
```

---

## Case 18: Valid 2016/01 Schema RDL (Synchronized Layout Node)

**Scenario:** Standard 2016/01 schema RDL with 3 defined parameters and matching 3-cell `<ReportParametersLayout>` definition.

**Evaluation:**
- Schema: `2016/01`.
- `count(ReportParameters) == count(CellDefinitions)`. Parameter names match, grid coordinates valid.

**Expected Output:**
```text
PREFLIGHT_STATUS = PASS
```
Blocking reason: Procedure contains DML write operations (UPDATE) which violate read-only safety rules and cannot be converted to report-local SQL.
Recommended implementation path: Blocked
```

---

## Case 7: Verification of Zero DDL Operations Against Stored Procedures

**Scenario:** Framework pipeline is checked to guarantee that under NO circumstance is an `ALTER PROCEDURE`, `CREATE PROCEDURE`, `CREATE OR ALTER PROCEDURE`, or `DROP PROCEDURE` emitted or executed.

**Evaluation:**
- Invariant: Stored Procedures are strictly immutable dependencies.
- Static Check: All SQL Agent skill rules and validation checks explicitly reject `ALTER`, `CREATE`, `DROP` statements targeting stored procedures with a `[BLOCKER]`.

**Expected Output:**
```text
PASSED: Zero DDL operations against stored procedures permitted by the framework.
```

---

## Case 8: Semantic & Parameter Preservation for `SAFE_CANDIDATE` Report-Local SQL

**Scenario:** A user requests: *"Add BuildDate to this report"*.
Target report dataset uses `SAFE_CANDIDATE` procedure `dbo.usp_rpt_CustomerSummary` (from Case 2).
Discovered schema reveals `soh.BuildDate` (or `c.CreatedDate` / confirmed column in joined table `sales.SalesOrderHeader`).

**Generated Report-Local SQL:**

```sql
SELECT
    c.CustomerID,
    c.AccountNumber,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    t.Name AS TerritoryName,
    ISNULL(SUM(soh.TotalDue), 0) AS TotalSales,
    CASE WHEN c.PersonID IS NOT NULL THEN 'Individual' ELSE 'Store' END AS CustomerType,
    soh.BuildDate -- Added report-specific field without altering stored procedure
FROM sales.Customer c
INNER JOIN sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
LEFT JOIN person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN sales.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
    AND soh.OrderDate >= @StartDate
    AND soh.OrderDate <= @EndDate
WHERE (@TerritoryID IS NULL OR c.TerritoryID = @TerritoryID)
GROUP BY
    c.CustomerID,
    c.AccountNumber,
    p.FirstName,
    p.LastName,
    t.Name,
    c.PersonID,
    soh.BuildDate;
```

**Preservation Checks:**
- Parameters `@StartDate`, `@EndDate`, `@TerritoryID` preserved.
- Joins and table relationships preserved.
- Existing calculated fields (`CustomerName`, `TotalSales`, `CustomerType`) preserved.
- Grouping grain preserved.
- Original procedure `dbo.usp_rpt_CustomerSummary` is **100% untouched**.

**Expected Output:**
```text
PASSED: Report-local SQL correctly generated with full semantic preservation and zero database object modification.
```
