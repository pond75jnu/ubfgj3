CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_previous
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL(MAX(seq), -1) AS before_retreat
      FROM ubfgj3.dbo.retreat_master
     WHERE seq < @RETREAT;
END

