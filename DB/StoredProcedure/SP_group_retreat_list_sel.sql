CREATE OR ALTER PROCEDURE [dbo].[SP_group_retreat_list_sel]
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm
      FROM ubfgj3.dbo.[groups]
     WHERE retreat = @Retreat
     ORDER BY belong_nm, seq;
END
GO
