CREATE OR ALTER PROCEDURE dbo.SP_meal_service_effective_get
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;
    DECLARE @ConfigRevision INT;

    SELECT @StartDate = TRY_CONVERT(DATE, retreat_sdt, 112),
           @EndDate = TRY_CONVERT(DATE, retreat_edt, 112)
      FROM dbo.retreat_master
     WHERE seq = @RETREAT;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 50301, N'수양회 날짜가 올바르지 않습니다.', 1;

    IF DATEDIFF(DAY, @StartDate, @EndDate) > 365
        THROW 50302, N'수양회 기간이 허용 범위를 초과했습니다.', 1;

    SELECT @ConfigRevision = ISNULL(MAX(config_revision), 0)
      FROM dbo.meal_service_config
     WHERE retreat = @RETREAT;

    ;WITH Dates AS
    (
        SELECT @StartDate AS meal_dt
        UNION ALL
        SELECT DATEADD(DAY, 1, meal_dt)
          FROM Dates
         WHERE meal_dt < @EndDate
    ),
    Meals AS
    (
        SELECT 'B' AS meal_type, N'아침' AS meal_name, 1 AS meal_order
        UNION ALL SELECT 'L', N'점심', 2
        UNION ALL SELECT 'D', N'저녁', 3
    )
    SELECT R.seq AS retreat,
           R.retreat_name,
           CONVERT(CHAR(8), @StartDate, 112) AS retreat_sdt,
           CONVERT(CHAR(8), @EndDate, 112) AS retreat_edt,
           CONVERT(CHAR(8), D.meal_dt, 112) AS meal_date,
           M.meal_type,
           M.meal_name,
           M.meal_order,
           ISNULL(C.provide_yn,
               CASE
                   WHEN @StartDate = @EndDate THEN 'Y'
                   WHEN D.meal_dt = @StartDate AND M.meal_type = 'D' THEN 'Y'
                   WHEN D.meal_dt = @EndDate AND M.meal_type IN ('B', 'L') THEN 'Y'
                   WHEN D.meal_dt > @StartDate AND D.meal_dt < @EndDate THEN 'Y'
                   ELSE 'N'
               END) AS provide_yn,
           CASE WHEN C.seq IS NULL THEN 'N' ELSE 'Y' END AS saved_yn,
           @ConfigRevision AS config_revision
      FROM dbo.retreat_master R
     CROSS JOIN Dates D
     CROSS JOIN Meals M
      LEFT JOIN dbo.meal_service_config C
        ON C.retreat = R.seq
       AND C.meal_date = CONVERT(CHAR(8), D.meal_dt, 112)
       AND C.meal_type = M.meal_type
     WHERE R.seq = @RETREAT
     ORDER BY D.meal_dt,
              M.meal_order
    OPTION (MAXRECURSION 366);
END
