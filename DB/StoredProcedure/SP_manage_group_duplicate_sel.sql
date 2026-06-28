CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_duplicate_sel]
    @BelongNm NVARCHAR(200),
    @Seq INT = NULL,
    @Retreat INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetRetreat INT = COALESCE(
        @Retreat,
        (SELECT retreat FROM ubfgj3.dbo.[groups] WHERE seq = @Seq)
    );

    SELECT belong_nm
      FROM ubfgj3.dbo.[groups]
     WHERE belong_nm = @BelongNm
       AND retreat = @TargetRetreat
       AND (@Seq IS NULL OR seq <> @Seq);
END
GO
