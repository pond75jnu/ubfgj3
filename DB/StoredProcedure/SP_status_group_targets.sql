CREATE OR ALTER PROCEDURE dbo.SP_status_group_targets
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH TEMP AS
    (
        SELECT -1 AS seq, N'0' AS belong_nm
        UNION
        SELECT seq, belong_nm
          FROM ubfgj3.dbo.groups
         WHERE ISNULL(etc1, N'') = N'Y'
           AND retreat = @RETREAT
    )
    SELECT seq,
           belong_nm
      FROM TEMP
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
              belong_nm ASC;
END

