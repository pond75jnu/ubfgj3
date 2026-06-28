CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_del]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.[groups]
     WHERE seq = @Seq;
END
GO
