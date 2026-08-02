SET XACT_ABORT ON;

BEGIN TRANSACTION;

IF EXISTS
(
    SELECT 1
      FROM sys.check_constraints
     WHERE parent_object_id = OBJECT_ID(N'dbo.group_members')
       AND name = N'CK_group_members_gender'
)
BEGIN
    ALTER TABLE dbo.group_members
        DROP CONSTRAINT CK_group_members_gender;
END;

IF COL_LENGTH(N'dbo.group_members', N'gender') IS NOT NULL
BEGIN
    ALTER TABLE dbo.group_members
        DROP COLUMN gender;
END;

COMMIT TRANSACTION;
