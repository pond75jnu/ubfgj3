CREATE OR ALTER PROCEDURE dbo.SP_group_seq_match_sel
    @Seq INT,
    @BelongNm NVARCHAR(200),
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.groups
     WHERE seq = @Seq
       AND belong_nm = @BelongNm
       AND retreat = @Retreat;
END

