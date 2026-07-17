CREATE OR ALTER PROCEDURE dbo.SP_meal_survey_members_get
    @RETREAT INT,
    @BELONG INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;
    DECLARE @ConfigRevision INT;
    DECLARE @MemberCount INT;
    DECLARE @RosterList NVARCHAR(MAX);
    DECLARE @RosterHash CHAR(64);

    SELECT @StartDate = TRY_CONVERT(DATE, retreat_sdt, 112),
           @EndDate = TRY_CONVERT(DATE, retreat_edt, 112)
      FROM dbo.retreat_master
     WHERE seq = @RETREAT;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 50351, N'수양회 날짜가 올바르지 않습니다.', 1;

    IF NOT EXISTS
    (
        SELECT 1
          FROM dbo.groups
         WHERE seq = @BELONG
           AND retreat = @RETREAT
           AND ISNULL(etc1, N'N') = N'Y'
    )
        THROW 50352, N'활성 요회 정보를 찾을 수 없습니다.', 1;

    SELECT @ConfigRevision = ISNULL(MAX(config_revision), 0)
      FROM dbo.meal_service_config
     WHERE retreat = @RETREAT;

    SELECT @MemberCount = COUNT(*),
           @RosterList = STRING_AGG(CONVERT(NVARCHAR(MAX), seq), N',')
                         WITHIN GROUP (ORDER BY seq)
      FROM dbo.group_members
     WHERE retreat = @RETREAT
       AND belong = @BELONG;

    SET @RosterHash = CONVERT(CHAR(64), HASHBYTES('SHA2_256', ISNULL(@RosterList, N'')), 2);

    SELECT G.seq AS belong,
           G.belong_nm,
           @MemberCount AS member_count,
           @RosterHash AS roster_hash,
           @ConfigRevision AS config_revision,
           ISNULL(H.revision, 0) AS submission_revision,
           ISNULL(H.entry_mode, 'P') AS entry_mode,
           H.submitted_dt,
           CASE WHEN H.seq IS NULL THEN N'NOT_SUBMITTED'
                WHEN H.roster_hash <> @RosterHash
                  OR H.meal_config_revision <> @ConfigRevision THEN N'RECHECK_REQUIRED'
                ELSE N'COMPLETED'
           END AS submission_status
      FROM dbo.groups G
      LEFT JOIN dbo.meal_survey_submission H
        ON H.retreat = @RETREAT
       AND H.belong = G.seq
     WHERE G.seq = @BELONG
       AND G.retreat = @RETREAT;

    SELECT M.seq AS group_member_seq,
           M.user_nm,
           ISNULL(M.usertype, 3) AS usertype,
           CASE ISNULL(M.usertype, 3)
                WHEN 1 THEN N'목자'
                WHEN 2 THEN N'목동'
                ELSE N'양'
           END AS usertype_name
      FROM dbo.group_members M
     WHERE M.retreat = @RETREAT
       AND M.belong = @BELONG
     ORDER BY M.seq;

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
    SELECT CONVERT(CHAR(8), D.meal_dt, 112) AS meal_date,
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
               END) AS provide_yn
      FROM Dates D
     CROSS JOIN Meals M
      LEFT JOIN dbo.meal_service_config C
        ON C.retreat = @RETREAT
       AND C.meal_date = CONVERT(CHAR(8), D.meal_dt, 112)
       AND C.meal_type = M.meal_type
     ORDER BY D.meal_dt,
              M.meal_order
    OPTION (MAXRECURSION 366);

    SELECT S.group_member_seq,
           S.meal_date,
           S.meal_type
      FROM dbo.meal_survey_submission H
     INNER JOIN dbo.meal_survey_selection S ON S.submission_seq = H.seq
     WHERE H.retreat = @RETREAT
       AND H.belong = @BELONG
     ORDER BY S.group_member_seq,
              S.meal_date,
              CASE S.meal_type WHEN 'B' THEN 1 WHEN 'L' THEN 2 ELSE 3 END;

    SELECT C.meal_date,
           C.meal_type,
           C.meal_count
      FROM dbo.meal_survey_submission H
     INNER JOIN dbo.meal_survey_manual_count C ON C.submission_seq = H.seq
     WHERE H.retreat = @RETREAT
       AND H.belong = @BELONG
       AND H.entry_mode = 'M'
     ORDER BY C.meal_date,
              CASE C.meal_type WHEN 'B' THEN 1 WHEN 'L' THEN 2 ELSE 3 END;
END
