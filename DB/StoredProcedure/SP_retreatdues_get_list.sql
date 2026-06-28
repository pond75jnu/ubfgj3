CREATE OR ALTER PROCEDURE dbo.SP_retreatdues_get_list
    @RETREAT INT,
    @SORT_DIRECTION VARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           dues_nm,
           dues,
           FORMAT(dues, N'#,0') + N' 원' AS dues_format,
           dues_desc
      FROM ubfgj3.dbo.retreatdues_master
     WHERE retreat = @RETREAT
     ORDER BY CASE WHEN UPPER(ISNULL(@SORT_DIRECTION, 'ASC')) = 'DESC' THEN dues_nm END DESC,
              CASE WHEN UPPER(ISNULL(@SORT_DIRECTION, 'ASC')) <> 'DESC' THEN dues_nm END ASC,
              seq ASC;
END

