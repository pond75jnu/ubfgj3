CREATE OR ALTER PROCEDURE dbo.SP_userinfo_userid_sel
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId);
END

