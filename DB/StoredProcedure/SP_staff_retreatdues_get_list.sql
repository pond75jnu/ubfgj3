CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_get_list]
    @retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER(ORDER BY dues_nm DESC, seq DESC) AS NUM,
           seq,
           retreat,
           dues_nm,
           dues,
           FORMAT(dues, N'#,0') + N' 원' AS dues_format,
           dues_desc
    FROM ubfgj3.dbo.retreatdues_master
    WHERE retreat = @retreat
    ORDER BY dues_nm, seq;
END
