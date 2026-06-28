CREATE OR ALTER PROCEDURE dbo.SP_menu_by_seq_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm,
           menu_path
      FROM ubfgj3.dbo.menu_master
     WHERE seq = @Seq;
END

