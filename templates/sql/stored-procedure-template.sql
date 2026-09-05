/*
    Name        : <schema>.<uspProcedureName>
    Purpose     : <one or two sentences on what this procedure does>
    Author/Agent: <name>
    Created     : <date>    Last modified: <date>
    Inputs      : <parameters>
    Outputs     : <result set / rows affected>
    Notes       : <assumptions, side effects, dependencies>

    Structural scaffold only. Parameterized and set-based. No production execution.
*/

CREATE OR ALTER PROCEDURE <schema>.<uspProcedureName>
    @Param1 <type>,
    @Param2 <type> = NULL          -- optional parameter with default
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Set-based logic. Never concatenate parameters into dynamic SQL.
        SELECT <columns>
        FROM   <schema>.<object>
        WHERE  <Column1> = @Param1
           AND (@Param2 IS NULL OR <Column2> = @Param2);
    END TRY
    BEGIN CATCH
        -- Surface the error to the caller; do not swallow silently.
        THROW;
    END CATCH;
END;
GO
