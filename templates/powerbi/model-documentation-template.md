# Power BI — Model Documentation Template

> Structural scaffold only. Copy per dataset/model and fill in. No real data.

## Model: <Model / Dataset Name>

- **Purpose:** <what this model supports>
- **Owner / Agent:** <name>
- **Source(s):** `<SOURCE_PLACEHOLDER>` (no connection strings here)
- **Last updated:** <date>

## Tables

| Table | Type (Fact/Dim) | Grain | Notes |
|-------|-----------------|-------|-------|
| `<Table>` | <Fact/Dim> | <one row per ...> | <...> |

## Relationships

| From | To | Cardinality | Cross-filter | Active |
|------|----|-------------|--------------|--------|
| `<Table1[Key]>` | `<Table2[Key]>` | <1:*> | <single/both> | <yes/no> |

## Key measures

| Measure | Purpose | Format |
|---------|---------|--------|
| `<Measure>` | <business definition> | <format> |

## Row-Level Security (RLS)

| Role | Filter | Restricts |
|------|--------|-----------|
| `<Role>` | `<DAX filter>` | <who sees what> |

## Notes & assumptions

- <refresh cadence, data volume, caveats>
