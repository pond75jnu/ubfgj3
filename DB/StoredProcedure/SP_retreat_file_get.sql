CREATE OR ALTER PROCEDURE dbo.SP_retreat_file_get
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT file_nm,
           file_data
      FROM ubfgj3.dbo.retreat_master
     WHERE seq = @SEQ;
END

