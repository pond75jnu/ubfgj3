CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_detail_sel]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm, manager, ISNULL(etc1, 'N') AS use_yn
      FROM ubfgj3.dbo.[groups]
     WHERE seq = @Seq;
END
GO
