CREATE OR ALTER PROCEDURE dbo.SP_menu_breadcrumb_current_sel
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT parent_seq,
           menu_depth,
           menu_nm
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@Path);
END

