/*
    Migration    : <NNN>_<short_description>
    Purpose      : <what schema change this applies and why>
    Author/Agent : <name>
    Created      : <date>
    Reversible   : <yes/no — see rollback section>

    Structural scaffold only. Review before running. Never run against production
    without explicit, user-approved, non-production context first.
*/

-------------------------------------------------------------------------------
-- UP (apply)
-------------------------------------------------------------------------------
BEGIN TRANSACTION;
BEGIN TRY

    -- Idempotent, guarded changes. Example:
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID(N'<schema>.<Table>')
          AND name = N'<NewColumn>'
    )
    BEGIN
        ALTER TABLE <schema>.<Table> ADD <NewColumn> <type> NULL;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- DOWN (rollback) — keep in sync with UP
-------------------------------------------------------------------------------
-- IF EXISTS ( ... ) ALTER TABLE <schema>.<Table> DROP COLUMN <NewColumn>;
-- GO
