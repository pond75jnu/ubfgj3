CREATE OR ALTER PROCEDURE dbo.SP_menu_top_nav_parent_sel
    @Auth NVARCHAR(50),
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.parent_seq,
           A.menu_nm,
           A.menu_path,
           A.menu_depth,
           A.menu_order,
           CASE WHEN EXISTS (SELECT 1 FROM ubfgj3.dbo.menu_master B WHERE B.parent_seq = A.seq) THEN 'Y' ELSE 'N' END AS subis,
           CASE WHEN EXISTS (SELECT 1 FROM ubfgj3.dbo.menu_master C WHERE C.parent_seq = A.seq AND LOWER(C.menu_path) = LOWER(@Path)) THEN 'Y' ELSE 'N' END AS pathis
      FROM ubfgj3.dbo.menu_master A
     WHERE (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(A.menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(A.menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(A.menu_auth) = 'anonymous')
           )
       AND A.menu_depth = 0
       AND ISNULL(A.menu_order, 0) <> 0
     ORDER BY A.menu_depth,
              A.parent_seq,
              A.menu_order;
END

