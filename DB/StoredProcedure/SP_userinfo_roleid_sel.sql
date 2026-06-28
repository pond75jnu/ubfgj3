CREATE OR ALTER PROCEDURE dbo.SP_userinfo_roleid_sel
    @RoleName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RoleId
      FROM ubfgj3.dbo.aspnet_Roles
     WHERE LoweredRoleName = LOWER(@RoleName);
END

