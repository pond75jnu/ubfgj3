CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_detail_sel]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.belong_nm,
           A.manager,
           ISNULL(A.etc1, 'N') AS use_yn,
           CASE WHEN EXISTS
                     (
                         SELECT 1
                           FROM ubfgj3.dbo.group_members B
                          INNER JOIN ubfgj3.dbo.[groups] C ON C.seq = B.belong
                          WHERE C.belong_nm = A.belong_nm
                     )
                THEN 'N' ELSE 'Y' END AS can_delete
      FROM ubfgj3.dbo.[groups] A
     WHERE A.seq = @Seq;
END
GO
