CREATE OR ALTER PROCEDURE dbo.SP_group_seq_by_name_sel
    @BelongNm NVARCHAR(200),
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.groups
     WHERE belong_nm = @BelongNm
       AND retreat = @Retreat;
END

