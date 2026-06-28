CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_file_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           file_nm,
           file_data
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

