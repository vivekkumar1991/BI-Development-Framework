# SSRS — Report Specification Template

> Structural scaffold only. Copy per report and fill in. No real data or credentials.

## Report: <Report Name>

- **Purpose:** <what decision/question this report serves>
- **Owner / Agent:** <name>
- **Data source:** `<SHARED_DATA_SOURCE_PLACEHOLDER>` (server-managed credentials; none here)
- **Last updated:** <date>

## Parameters

| Name | Type | Default | Allowed values | Required |
|------|------|---------|----------------|----------|
| `<StartDate>` | Date/Time | <default> | <range/list> | Yes |
| `<RegionId>` | Integer | <default> | <query/list> | No |

## Datasets

| Dataset | Purpose | Parameters used | Notes |
|---------|---------|-----------------|-------|
| `<dsMain>` | <...> | `@StartDate`, `@RegionId` | Parameterized query — no string concat |

### Dataset query (parameterized)

```sql
-- Parameterized only. Never concatenate parameter values into the query text.
SELECT <columns>
FROM   <schema>.<object>
WHERE  <DateColumn> >= @StartDate
   AND (@RegionId IS NULL OR <RegionColumn> = @RegionId);
```

## Layout

- **Header:** <title, logo, run date, parameters echo>
- **Body:** <tablix / matrix / chart summary>
- **Footer:** <page numbers, confidentiality note>

## Notes

- <grouping, sorting, drill-through, subscription intent>
