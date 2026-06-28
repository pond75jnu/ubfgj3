CREATE OR ALTER PROCEDURE dbo.SP_group_get_previous_by_name
    @RETREAT INT,
    @BELONG_NM NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL(MAX(seq), -1) AS before_belong
      FROM ubfgj3.dbo.groups
     WHERE retreat = @RETREAT
       AND belong_nm = @BELONG_NM;
END

