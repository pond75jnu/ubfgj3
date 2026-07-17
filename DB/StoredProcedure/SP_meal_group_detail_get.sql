CREATE OR ALTER PROCEDURE dbo.SP_meal_group_detail_get
    @RETREAT INT,
    @BELONG INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
          FROM dbo.groups
         WHERE seq = @BELONG
           AND retreat = @RETREAT
           AND ISNULL(etc1, N'N') = N'Y'
    )
        THROW 50381, N'활성 요회 정보를 찾을 수 없습니다.', 1;

    EXEC dbo.SP_meal_survey_members_get
         @RETREAT = @RETREAT,
         @BELONG = @BELONG;
END
