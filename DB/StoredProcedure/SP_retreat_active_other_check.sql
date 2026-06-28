CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_other_check
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
       AND seq <> @SEQ;
END

