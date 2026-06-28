CREATE OR ALTER PROCEDURE dbo.SP_retreat_name_duplicate_check
    @RETREAT_NAME NVARCHAR(100),
    @SEQ INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT retreat_name
      FROM ubfgj3.dbo.retreat_master
     WHERE retreat_name = @RETREAT_NAME
       AND (@SEQ IS NULL OR seq <> @SEQ);
END

