CREATE OR ALTER PROCEDURE dbo.SP_menu_auth_by_path_sel
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE WHEN LOWER(menu_auth) = 'user' THEN 'admin/manager/user'
                WHEN LOWER(menu_auth) = 'manager' THEN 'admin/manager'
                ELSE LOWER(menu_auth)
           END AS menu_auth
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@Path);
END

