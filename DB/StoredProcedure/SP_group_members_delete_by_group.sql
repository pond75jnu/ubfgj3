CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_by_group
    @RETREAT INT,
    @BELONG INT,
    @DELETE_CONFIRMED CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @RETREAT
       AND belong = @BELONG
       AND
       (
           @DELETE_CONFIRMED = 'Y'
           OR
           (
               ISNULL(manager_confirm, 'N') = 'N'
               AND ISNULL(etc1, N'N') = N'N'
           )
       );
END

