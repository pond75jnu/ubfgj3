CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_del]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE A
      FROM ubfgj3.dbo.[groups] A
     WHERE A.seq = @Seq
       AND NOT EXISTS
           (
               SELECT 1
                 FROM ubfgj3.dbo.group_members B
                INNER JOIN ubfgj3.dbo.[groups] C ON C.seq = B.belong
                WHERE C.belong_nm = A.belong_nm
           );
END
GO
