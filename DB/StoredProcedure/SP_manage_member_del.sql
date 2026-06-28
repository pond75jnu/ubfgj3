CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_del]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId)
        OR LOWER(UserName) = LOWER(@LoginId);

    BEGIN TRANSACTION;

    DELETE FROM ubfgj3.dbo.aspnet_UsersInRoles
     WHERE UserId = @UserId;

    DELETE FROM ubfgj3.dbo.aspnet_Membership
     WHERE UserId = @UserId;

    DELETE FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId);

    DELETE FROM ubfgj3.dbo.member_master
     WHERE LOWER(login_id) = LOWER(@LoginId);

    COMMIT TRANSACTION;
END
GO
