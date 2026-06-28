CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_get
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           seq,
           retreat_name
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

