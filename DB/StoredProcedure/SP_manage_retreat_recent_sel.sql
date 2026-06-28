CREATE OR ALTER PROCEDURE [dbo].[SP_manage_retreat_recent_sel]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (10) seq, retreat_name
      FROM ubfgj3.dbo.retreat_master
     ORDER BY seq DESC;
END
GO
