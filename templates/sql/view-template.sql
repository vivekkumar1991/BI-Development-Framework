/*
    Name        : <schema>.<vwViewName>
    Purpose     : <what this view exposes and why>
    Author/Agent: <name>
    Created     : <date>    Last modified: <date>
    Depends on  : <base tables/views>
    Notes       : <grain, filters applied, performance considerations>

    Structural scaffold only. Schema-qualified, sargable, documented.
*/

CREATE OR ALTER VIEW <schema>.<vwViewName>
AS
SELECT
    <column1>,
    <column2>,
    <derived_column> = <expression>
FROM   <schema>.<BaseTable>  AS b
JOIN   <schema>.<DimTable>   AS d
       ON d.<Key> = b.<Key>
WHERE  <sargable_predicate>;   -- avoid wrapping filtered columns in functions
GO
