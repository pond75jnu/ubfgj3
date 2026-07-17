CREATE OR ALTER PROCEDURE dbo.SP_meal_survey_groups_get
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           CASE WHEN belong_nm LIKE N'%센터' THEN belong_nm
                ELSE belong_nm + N' 요회' END AS belong_nm
      FROM dbo.groups
     WHERE retreat = @RETREAT
       AND ISNULL(etc1, N'N') = N'Y'
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END,
              belong_nm,
              seq;
END
