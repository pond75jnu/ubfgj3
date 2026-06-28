CREATE OR ALTER PROCEDURE dbo.SP_menu_left_by_path_auth_sel
    @Path NVARCHAR(400),
    @Auth NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm,
           menu_path,
           menu_auth
      FROM ubfgj3.dbo.menu_master
     WHERE parent_seq = (
               SELECT parent_seq
                 FROM ubfgj3.dbo.menu_master
                WHERE LOWER(menu_path) = LOWER(@Path)
           )
       AND (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(menu_auth) = 'anonymous')
           )
     ORDER BY menu_order;
END

