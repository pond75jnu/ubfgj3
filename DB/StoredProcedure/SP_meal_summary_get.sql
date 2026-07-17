CREATE OR ALTER PROCEDURE dbo.SP_meal_summary_get
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
        THROW 50371, N'수양회 날짜가 올바르지 않습니다.', 1;

    SELECT @ConfigRevision = ISNULL(MAX(config_revision), 0)
      FROM dbo.meal_service_config
     WHERE retreat = @RETREAT;

    DECLARE @Effective TABLE
    (
        meal_date CHAR(8) NOT NULL,
        meal_type CHAR(1) NOT NULL,
        meal_name NVARCHAR(10) NOT NULL,
        meal_order INT NOT NULL,
        provide_yn CHAR(1) NOT NULL,
        PRIMARY KEY (meal_date, meal_type)
    );

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
    INSERT INTO @Effective (meal_date, meal_type, meal_name, meal_order, provide_yn)
    SELECT CONVERT(CHAR(8), D.meal_dt, 112),
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
               END)
      FROM Dates D
     CROSS JOIN Meals M
      LEFT JOIN dbo.meal_service_config C
        ON C.retreat = @RETREAT
       AND C.meal_date = CONVERT(CHAR(8), D.meal_dt, 112)
       AND C.meal_type = M.meal_type
    OPTION (MAXRECURSION 366);

    DECLARE @GroupInfo TABLE
    (
        belong INT NOT NULL PRIMARY KEY,
        belong_nm NVARCHAR(200) NOT NULL,
        member_count INT NOT NULL DEFAULT (0),
        roster_hash CHAR(64) NULL,
        selected_member_count INT NOT NULL DEFAULT (0),
        submission_status NVARCHAR(30) NOT NULL DEFAULT (N'NOT_SUBMITTED'),
        submitted_dt DATETIME2(0) NULL,
        submission_revision INT NOT NULL DEFAULT (0)
    );

    INSERT INTO @GroupInfo (belong, belong_nm)
    SELECT seq,
           belong_nm
      FROM dbo.groups
     WHERE retreat = @RETREAT
       AND ISNULL(etc1, N'N') = N'Y';

    UPDATE I
       SET member_count = X.member_count,
           roster_hash = CONVERT(CHAR(64), HASHBYTES('SHA2_256', ISNULL(X.roster_list, N'')), 2)
      FROM @GroupInfo I
     CROSS APPLY
     (
         SELECT COUNT(*) AS member_count,
                STRING_AGG(CONVERT(NVARCHAR(MAX), M.seq), N',')
                    WITHIN GROUP (ORDER BY M.seq) AS roster_list
           FROM dbo.group_members M
          WHERE M.retreat = @RETREAT
            AND M.belong = I.belong
     ) X;

    UPDATE I
       SET submitted_dt = H.submitted_dt,
           submission_revision = ISNULL(H.revision, 0),
           submission_status =
               CASE WHEN H.seq IS NULL THEN N'NOT_SUBMITTED'
                    WHEN H.roster_hash <> I.roster_hash
                      OR H.meal_config_revision <> @ConfigRevision THEN N'RECHECK_REQUIRED'
                    ELSE N'COMPLETED'
               END
      FROM @GroupInfo I
      LEFT JOIN dbo.meal_survey_submission H
        ON H.retreat = @RETREAT
       AND H.belong = I.belong;

    UPDATE I
       SET selected_member_count = X.selected_member_count
      FROM @GroupInfo I
     CROSS APPLY
     (
         SELECT COUNT(DISTINCT S.group_member_seq) AS selected_member_count
           FROM dbo.meal_survey_submission H
          INNER JOIN dbo.meal_survey_selection S ON S.submission_seq = H.seq
          INNER JOIN @Effective E
             ON E.meal_date = S.meal_date
            AND E.meal_type = S.meal_type
            AND E.provide_yn = 'Y'
          WHERE H.retreat = @RETREAT
            AND H.belong = I.belong
     ) X;

    DECLARE @GroupCount INT = (SELECT COUNT(*) FROM @GroupInfo);
    DECLARE @SubmittedGroupCount INT =
    (
        SELECT COUNT(*)
          FROM @GroupInfo
         WHERE submission_status <> N'NOT_SUBMITTED'
    );

    SELECT R.is_total,
           R.belong,
           R.belong_nm,
           R.member_count,
           R.selected_member_count,
           R.submission_status,
           R.submitted_dt,
           R.submission_revision,
           R.submitted_group_count,
           R.group_count
      FROM
      (
          SELECT 1 AS is_total,
                 -1 AS belong,
                 N'전체' AS belong_nm,
                 ISNULL(SUM(member_count), 0) AS member_count,
                 ISNULL(SUM(selected_member_count), 0) AS selected_member_count,
                 N'SUMMARY' AS submission_status,
                 CAST(NULL AS DATETIME2(0)) AS submitted_dt,
                 0 AS submission_revision,
                 @SubmittedGroupCount AS submitted_group_count,
                 @GroupCount AS group_count
            FROM @GroupInfo
          UNION ALL
          SELECT 0,
                 belong,
                 belong_nm,
                 member_count,
                 selected_member_count,
                 submission_status,
                 submitted_dt,
                 submission_revision,
                 CASE WHEN submission_status = N'NOT_SUBMITTED' THEN 0 ELSE 1 END,
                 1
            FROM @GroupInfo
      ) R
     ORDER BY R.is_total DESC,
              CASE WHEN R.belong_nm LIKE N'%센터' THEN 2 ELSE 1 END,
              R.belong_nm,
              R.belong;

    DECLARE @Targets TABLE
    (
        belong INT NOT NULL PRIMARY KEY,
        belong_nm NVARCHAR(200) NOT NULL,
        is_total BIT NOT NULL
    );

    INSERT INTO @Targets (belong, belong_nm, is_total)
    VALUES (-1, N'전체', 1);

    INSERT INTO @Targets (belong, belong_nm, is_total)
    SELECT belong, belong_nm, 0
      FROM @GroupInfo;

    SELECT T.belong,
           T.belong_nm,
           T.is_total,
           E.meal_date,
           E.meal_type,
           E.meal_name,
           E.meal_order,
           E.provide_yn,
           CASE WHEN E.provide_yn = 'N' THEN NULL
                ELSE
                (
                    SELECT COUNT(DISTINCT S.group_member_seq)
                      FROM dbo.meal_survey_submission H
                     INNER JOIN dbo.meal_survey_selection S ON S.submission_seq = H.seq
                     INNER JOIN dbo.groups G
                        ON G.seq = H.belong
                       AND G.retreat = H.retreat
                       AND ISNULL(G.etc1, N'N') = N'Y'
                     WHERE H.retreat = @RETREAT
                       AND (T.is_total = 1 OR H.belong = T.belong)
                       AND S.meal_date = E.meal_date
                       AND S.meal_type = E.meal_type
                )
           END AS meal_count
      FROM @Targets T
     CROSS JOIN @Effective E
     ORDER BY T.is_total DESC,
              CASE WHEN T.belong_nm LIKE N'%센터' THEN 2 ELSE 1 END,
              T.belong_nm,
              E.meal_date,
              E.meal_order;
END
