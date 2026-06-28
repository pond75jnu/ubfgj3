CREATE OR ALTER PROCEDURE [dbo].[SP_member_chk_id_sel]
    @UserName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@UserName);
END
GO
