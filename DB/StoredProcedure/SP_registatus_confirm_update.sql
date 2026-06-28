CREATE OR ALTER PROCEDURE dbo.SP_registatus_confirm_update
    @SEQ INT,
    @MANAGER_CONFIRM CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.group_members
       SET manager_confirm = @MANAGER_CONFIRM,
           etc1 = CASE WHEN ISNULL(etc1, N'N') = N'N' THEN @MANAGER_CONFIRM ELSE etc1 END
     WHERE seq = @SEQ;
END

