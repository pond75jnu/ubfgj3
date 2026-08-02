SET XACT_ABORT ON;

BEGIN TRANSACTION;

IF COL_LENGTH(N'dbo.group_members', N'gender') IS NULL
BEGIN
    EXEC(N'ALTER TABLE dbo.group_members ADD gender CHAR(1) NULL;');
END;

IF NOT EXISTS
(
    SELECT 1
      FROM sys.check_constraints
     WHERE parent_object_id = OBJECT_ID(N'dbo.group_members')
       AND name = N'CK_group_members_gender'
)
BEGIN
    EXEC(N'ALTER TABLE dbo.group_members WITH CHECK
        ADD CONSTRAINT CK_group_members_gender
        CHECK (gender IS NULL OR gender IN (''M'', ''F''));');
END;

COMMIT TRANSACTION;
