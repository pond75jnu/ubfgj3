CREATE OR ALTER PROCEDURE [dbo].[SP_group_all_list_sel]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm
      FROM ubfgj3.dbo.[groups]
     ORDER BY belong_nm, seq;
END
GO
