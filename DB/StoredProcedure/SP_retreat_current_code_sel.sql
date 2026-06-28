CREATE OR ALTER PROCEDURE dbo.SP_retreat_current_code_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq,
           retreat_name
      FROM ubfgj3.dbo.retreat_master
     ORDER BY CASE WHEN ISNULL(retreat_yn, 'N') = 'Y' THEN 0 ELSE 1 END,
              seq DESC;
END

