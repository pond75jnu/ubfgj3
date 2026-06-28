CREATE OR ALTER PROCEDURE dbo.SP_menu_page_title_sel
    @MenuPath NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@MenuPath);
END

