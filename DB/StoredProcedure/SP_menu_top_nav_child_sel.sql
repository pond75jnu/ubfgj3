CREATE OR ALTER PROCEDURE dbo.SP_menu_top_nav_child_sel
    @Auth NVARCHAR(50),
    @ParentSeq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           parent_seq,
           menu_nm,
           menu_path,
           menu_depth,
           menu_order
      FROM ubfgj3.dbo.menu_master
     WHERE (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(menu_auth) = 'anonymous')
           )
       AND menu_depth = 1
       AND parent_seq = @ParentSeq
     ORDER BY menu_depth,
              menu_order;
END

