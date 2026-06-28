CREATE OR ALTER PROCEDURE dbo.SP_group_name_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE WHEN belong_nm LIKE N'%센터' THEN belong_nm ELSE belong_nm + N' 요회' END AS belong_nm
      FROM ubfgj3.dbo.groups
     WHERE seq = @Seq;
END
