CREATE OR ALTER PROCEDURE dbo.SP_userinfo_role_by_userid_sel
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT B.LoweredRoleName AS UserRole,
           B.Description AS RoleDesc
      FROM ubfgj3.dbo.aspnet_UsersInRoles A
     INNER JOIN ubfgj3.dbo.aspnet_Roles B ON B.RoleId = A.RoleId
     WHERE A.UserId = @UserId;
END

