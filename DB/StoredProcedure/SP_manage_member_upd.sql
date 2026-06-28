CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_upd]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @Email NVARCHAR(256),
    @Status NVARCHAR(10),
    @RoleName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;
    DECLARE @RoleId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@LoginId);

    SELECT @RoleId = RoleId
      FROM ubfgj3.dbo.aspnet_Roles
     WHERE LoweredRoleName = LOWER(@RoleName)
        OR LOWER(RoleName) = LOWER(@RoleName);

    BEGIN TRANSACTION;

    UPDATE ubfgj3.dbo.aspnet_Membership
       SET Email = @Email,
           LoweredEmail = LOWER(@Email),
           IsApproved = CASE WHEN @Status = '1' THEN 1 ELSE 0 END
     WHERE UserId = @UserId;

    UPDATE ubfgj3.dbo.member_master
       SET kor_nm = @KorNm,
           belong = @Belong,
           email = @Email
     WHERE LOWER(login_id) = LOWER(@LoginId);

    IF @RoleId IS NOT NULL
    BEGIN
        UPDATE ubfgj3.dbo.aspnet_UsersInRoles
           SET RoleId = @RoleId
         WHERE UserId = @UserId;
    END

    COMMIT TRANSACTION;
END
GO
