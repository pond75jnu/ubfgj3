CREATE OR ALTER PROCEDURE dbo.SP_meal_service_save
    @RETREAT INT,
    @EXPECTED_REVISION INT,
    @CONFIG_XML XML,
    @FORCE CHAR(1),
    @UID NVARCHAR(50),
    @UIP NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EXPECTED_REVISION < 0
        THROW 50341, N'설정 revision이 올바르지 않습니다.', 1;

    IF @FORCE NOT IN ('Y', 'N')
        THROW 50342, N'강제 저장 값이 올바르지 않습니다.', 1;

    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;

    SELECT @StartDate = TRY_CONVERT(DATE, retreat_sdt, 112),
           @EndDate = TRY_CONVERT(DATE, retreat_edt, 112)
      FROM dbo.retreat_master
     WHERE seq = @RETREAT;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 50343, N'수양회 날짜가 올바르지 않습니다.', 1;

    IF DATEDIFF(DAY, @StartDate, @EndDate) > 365
        THROW 50344, N'수양회 기간이 허용 범위를 초과했습니다.', 1;

    DECLARE @RawConfig TABLE
    (
        meal_date NVARCHAR(30) NULL,
        meal_type NVARCHAR(10) NULL,
        provide_yn NVARCHAR(10) NULL
    );

    INSERT INTO @RawConfig (meal_date, meal_type, provide_yn)
    SELECT T.N.value(N'@date', N'nvarchar(30)'),
           T.N.value(N'@type', N'nvarchar(10)'),
           T.N.value(N'@provided', N'nvarchar(10)')
      FROM @CONFIG_XML.nodes(N'/config/item') AS T(N);

    IF EXISTS
    (
        SELECT 1
          FROM @RawConfig
         WHERE LEN(ISNULL(meal_date, N'')) <> 8
            OR meal_date LIKE N'%[^0-9]%'
            OR meal_type NOT IN (N'B', N'L', N'D')
            OR provide_yn NOT IN (N'Y', N'N')
            OR TRY_CONVERT(DATE, meal_date, 112) IS NULL
    )
        THROW 50345, N'식사 설정 payload가 올바르지 않습니다.', 1;

    IF EXISTS
    (
        SELECT meal_date, meal_type
          FROM @RawConfig
         GROUP BY meal_date, meal_type
        HAVING COUNT(*) <> 1
    )
        THROW 50346, N'식사 설정 payload에 중복 항목이 있습니다.', 1;

    DECLARE @ExpectedCount INT = (DATEDIFF(DAY, @StartDate, @EndDate) + 1) * 3;

    IF (SELECT COUNT(*) FROM @RawConfig) <> @ExpectedCount
        THROW 50347, N'식사 설정 항목 수가 수양회 기간과 일치하지 않습니다.', 1;

    IF EXISTS
    (
        SELECT 1
          FROM @RawConfig
         WHERE TRY_CONVERT(DATE, meal_date, 112) < @StartDate
            OR TRY_CONVERT(DATE, meal_date, 112) > @EndDate
    )
        THROW 50348, N'수양회 기간 밖의 식사 설정이 있습니다.', 1;

    DECLARE @Config TABLE
    (
        meal_date CHAR(8) NOT NULL,
        meal_type CHAR(1) NOT NULL,
        provide_yn CHAR(1) NOT NULL,
        PRIMARY KEY (meal_date, meal_type)
    );

    INSERT INTO @Config (meal_date, meal_type, provide_yn)
    SELECT CONVERT(CHAR(8), meal_date),
           CONVERT(CHAR(1), meal_type),
           CONVERT(CHAR(1), provide_yn)
      FROM @RawConfig;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        DECLARE @CurrentRevision INT;
        DECLARE @MinRevision INT;

        SELECT @CurrentRevision = ISNULL(MAX(config_revision), 0),
               @MinRevision = ISNULL(MIN(config_revision), 0)
          FROM dbo.meal_service_config WITH (UPDLOCK, HOLDLOCK)
         WHERE retreat = @RETREAT;

        IF @CurrentRevision <> @MinRevision
            THROW 50349, N'저장된 식사 설정 revision이 일치하지 않습니다.', 1;

        IF @CurrentRevision <> @EXPECTED_REVISION
        BEGIN
            COMMIT TRANSACTION;
            SELECT N'CONFLICT' AS result_code,
                   N'다른 사용자가 먼저 식사 설정을 변경했습니다.' AS result_message,
                   @CurrentRevision AS config_revision,
                   0 AS affected_count;
            RETURN;
        END;

        DECLARE @Current TABLE
        (
            meal_date CHAR(8) NOT NULL,
            meal_type CHAR(1) NOT NULL,
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
            SELECT 'B' AS meal_type
            UNION ALL SELECT 'L'
            UNION ALL SELECT 'D'
        )
        INSERT INTO @Current (meal_date, meal_type, provide_yn)
        SELECT CONVERT(CHAR(8), D.meal_dt, 112),
               M.meal_type,
               ISNULL(S.provide_yn,
                   CASE
                       WHEN @StartDate = @EndDate THEN 'Y'
                       WHEN D.meal_dt = @StartDate AND M.meal_type = 'D' THEN 'Y'
                       WHEN D.meal_dt = @EndDate AND M.meal_type IN ('B', 'L') THEN 'Y'
                       WHEN D.meal_dt > @StartDate AND D.meal_dt < @EndDate THEN 'Y'
                       ELSE 'N'
                   END)
          FROM Dates D
         CROSS JOIN Meals M
          LEFT JOIN dbo.meal_service_config S
            ON S.retreat = @RETREAT
           AND S.meal_date = CONVERT(CHAR(8), D.meal_dt, 112)
           AND S.meal_type = M.meal_type
        OPTION (MAXRECURSION 366);

        IF NOT EXISTS
        (
            SELECT 1
              FROM @Current C
             INNER JOIN @Config N
                ON N.meal_date = C.meal_date
               AND N.meal_type = C.meal_type
             WHERE N.provide_yn <> C.provide_yn
        )
        BEGIN
            COMMIT TRANSACTION;
            SELECT N'NO_CHANGE' AS result_code,
                   N'변경된 식사 설정이 없습니다.' AS result_message,
                   @CurrentRevision AS config_revision,
                   0 AS affected_count;
            RETURN;
        END;

        DECLARE @AffectedCount INT;

        SELECT @AffectedCount = COUNT(*)
          FROM dbo.meal_survey_selection S
         INNER JOIN dbo.meal_survey_submission H
            ON H.seq = S.submission_seq
           AND H.retreat = @RETREAT
         INNER JOIN @Current C
            ON C.meal_date = S.meal_date
           AND C.meal_type = S.meal_type
           AND C.provide_yn = 'Y'
         INNER JOIN @Config N
            ON N.meal_date = S.meal_date
           AND N.meal_type = S.meal_type
           AND N.provide_yn = 'N';

        SELECT @AffectedCount = ISNULL(@AffectedCount, 0) + ISNULL(SUM(C.meal_count), 0)
          FROM dbo.meal_survey_manual_count C
         INNER JOIN dbo.meal_survey_submission H
            ON H.seq = C.submission_seq
           AND H.retreat = @RETREAT
           AND H.entry_mode = 'M'
         INNER JOIN @Current O
            ON O.meal_date = C.meal_date
           AND O.meal_type = C.meal_type
           AND O.provide_yn = 'Y'
         INNER JOIN @Config N
            ON N.meal_date = C.meal_date
           AND N.meal_type = C.meal_type
           AND N.provide_yn = 'N';

        IF ISNULL(@AffectedCount, 0) > 0 AND @FORCE = 'N'
        BEGIN
            COMMIT TRANSACTION;
            SELECT N'CONFIRM_REQUIRED' AS result_code,
                   N'제공하지 않는 식사로 변경하면 기존 선택 또는 직접입력 수량이 삭제됩니다.' AS result_message,
                   @CurrentRevision AS config_revision,
                   @AffectedCount AS affected_count;
            RETURN;
        END;

        DECLARE @NewRevision INT = @CurrentRevision + 1;

        UPDATE S
           SET provide_yn = C.provide_yn,
               config_revision = @NewRevision,
               upt_id = @UID,
               upt_ip = @UIP,
               upt_dt = GETDATE()
          FROM dbo.meal_service_config S
         INNER JOIN @Config C
            ON C.meal_date = S.meal_date
           AND C.meal_type = S.meal_type
         WHERE S.retreat = @RETREAT;

        INSERT INTO dbo.meal_service_config
        (
            retreat,
            meal_date,
            meal_type,
            provide_yn,
            config_revision,
            ins_id,
            ins_ip,
            ins_dt
        )
        SELECT @RETREAT,
               C.meal_date,
               C.meal_type,
               C.provide_yn,
               @NewRevision,
               @UID,
               @UIP,
               GETDATE()
          FROM @Config C
         WHERE NOT EXISTS
               (
                   SELECT 1
                     FROM dbo.meal_service_config S
                    WHERE S.retreat = @RETREAT
                      AND S.meal_date = C.meal_date
                      AND S.meal_type = C.meal_type
               );

        DELETE S
          FROM dbo.meal_service_config S
         WHERE S.retreat = @RETREAT
           AND (S.meal_date < CONVERT(CHAR(8), @StartDate, 112)
             OR S.meal_date > CONVERT(CHAR(8), @EndDate, 112));

        DELETE S
          FROM dbo.meal_survey_selection S
         INNER JOIN dbo.meal_survey_submission H
            ON H.seq = S.submission_seq
           AND H.retreat = @RETREAT
         WHERE S.meal_date < CONVERT(CHAR(8), @StartDate, 112)
            OR S.meal_date > CONVERT(CHAR(8), @EndDate, 112);

        DELETE C
          FROM dbo.meal_survey_manual_count C
         INNER JOIN dbo.meal_survey_submission H
            ON H.seq = C.submission_seq
           AND H.retreat = @RETREAT
         WHERE C.meal_date < CONVERT(CHAR(8), @StartDate, 112)
            OR C.meal_date > CONVERT(CHAR(8), @EndDate, 112);

        IF @FORCE = 'Y'
        BEGIN
            DELETE S
              FROM dbo.meal_survey_selection S
             INNER JOIN dbo.meal_survey_submission H
                ON H.seq = S.submission_seq
               AND H.retreat = @RETREAT
             INNER JOIN @Config C
                ON C.meal_date = S.meal_date
               AND C.meal_type = S.meal_type
               AND C.provide_yn = 'N';

            DELETE C
              FROM dbo.meal_survey_manual_count C
             INNER JOIN dbo.meal_survey_submission H
                ON H.seq = C.submission_seq
               AND H.retreat = @RETREAT
             INNER JOIN @Config N
                ON N.meal_date = C.meal_date
               AND N.meal_type = C.meal_type
               AND N.provide_yn = 'N';
        END;

        COMMIT TRANSACTION;

        SELECT N'SAVED' AS result_code,
               N'식사 제공 설정을 저장했습니다.' AS result_message,
               @NewRevision AS config_revision,
               ISNULL(@AffectedCount, 0) AS affected_count;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
