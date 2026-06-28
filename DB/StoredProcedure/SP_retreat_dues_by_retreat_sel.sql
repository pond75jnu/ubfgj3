CREATE OR ALTER PROCEDURE dbo.SP_retreat_dues_by_retreat_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.retreat,
           A.dues_nm,
           A.dues,
           FORMAT(A.dues, N'#,0') + N' 원' AS dues_format,
           A.dues_desc,
           B.etc1 AS bank_no
      FROM ubfgj3.dbo.retreatdues_master A
      LEFT OUTER JOIN ubfgj3.dbo.retreat_master B ON B.seq = A.retreat
     WHERE A.retreat = @Retreat
     ORDER BY A.dues_nm DESC,
              A.seq;
END
