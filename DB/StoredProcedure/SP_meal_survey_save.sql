CREATE OR ALTER PROCEDURE dbo.SP_meal_survey_save
    @RETREAT INT,
    @BELONG INT,
    @EXPECTED_REVISION INT,
    @SELECTION_XML XML,
    @MANUAL_COUNT_XML XML,
    @BROWSER_KEY_HASH CHAR(64),
    @IP_HASH CHAR(64),
    @UID NVARCHAR(50),
    @UIP NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EXPECTED_REVISION < 0
        THROW 50361, N'제출 revision이 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@BROWSER_KEY_HASH, '')) <> 64 OR @BROWSER_KEY_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50362, N'브라우저 식별 해시가 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@IP_HASH, '')) <> 64 OR @IP_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50363, N'IP 식별 해시가 올바르지 않습니다.', 1;

    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;

    SELECT TOP (1)
           @StartDate = TRY_CONVERT(DATE, retreat_sdt, 112),
           @EndDate = TRY_CONVERT(DATE, retreat_edt, 112)
      FROM dbo.retreat_master
     WHERE seq = @RETREAT
       AND ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 50364, N'현재 사용 중인 수양회가 아니거나 날짜가 올바르지 않습니다.', 1;

    IF NOT EXISTS
    (
        SELECT 1
          FROM dbo.groups
         WHERE seq = @BELONG
           AND retreat = @RETREAT
           AND ISNULL(etc1, N'N') = N'Y'
    )
        THROW 50365, N'활성 요회 정보를 찾을 수 없습니다.', 1;

    DECLARE @RawSelection TABLE
    (
        group_member_seq_text NVARCHAR(30) NULL,
        meal_date NVARCHAR(30) NULL,
        meal_type NVARCHAR(10) NULL
    );

    INSERT INTO @RawSelection (group_member_seq_text, meal_date, meal_type)
    SELECT T.N.value(N'@member', N'nvarchar(30)'),
           T.N.value(N'@date', N'nvarchar(30)'),
           T.N.value(N'@type', N'nvarchar(10)')
      FROM @SELECTION_XML.nodes(N'/selections/item') AS T(N);

    IF EXISTS
    (
        SELECT 1
          FROM @RawSelection
         WHERE TRY_CONVERT(INT, group_member_seq_text) IS NULL
            OR TRY_CONVERT(INT, group_member_seq_text) <= 0
            OR LEN(ISNULL(meal_date, N'')) <> 8
            OR meal_date LIKE N'%[^0-9]%'
            OR TRY_CONVERT(DATE, meal_date, 112) IS NULL
            OR meal_type NOT IN (N'B', N'L', N'D')
    )
        THROW 50366, N'식사 선택 payload가 올바르지 않습니다.', 1;

    IF EXISTS
    (
        SELECT group_member_seq_text, meal_date, meal_type
          FROM @RawSelection
         GROUP BY group_member_seq_text, meal_date, meal_type
        HAVING COUNT(*) <> 1
    )
        THROW 50367, N'식사 선택 payload에 중복 항목이 있습니다.', 1;

    DECLARE @Selection TABLE
    (
        group_member_seq INT NOT NULL,
        meal_date CHAR(8) NOT NULL,
        meal_type CHAR(1) NOT NULL,
        PRIMARY KEY (group_member_seq, meal_date, meal_type)
    );

    INSERT INTO @Selection (group_member_seq, meal_date, meal_type)
    SELECT TRY_CONVERT(INT, group_member_seq_text),
           CONVERT(CHAR(8), meal_date),
           CONVERT(CHAR(1), meal_type)
      FROM @RawSelection;

    DECLARE @RawManualCount TABLE
    (
        meal_date NVARCHAR(30) NULL,
        meal_type NVARCHAR(10) NULL,
        meal_count_text NVARCHAR(30) NULL
    );

    INSERT INTO @RawManualCount (meal_date, meal_type, meal_count_text)
    SELECT T.N.value(N'@date', N'nvarchar(30)'),
           T.N.value(N'@type', N'nvarchar(10)'),
           T.N.value(N'@count', N'nvarchar(30)')
      FROM @MANUAL_COUNT_XML.nodes(N'/counts/item') AS T(N);

    IF EXISTS
    (
        SELECT 1
          FROM @RawManualCount
         WHERE LEN(ISNULL(meal_date, N'')) <> 8
            OR meal_date LIKE N'%[^0-9]%'
            OR TRY_CONVERT(DATE, meal_date, 112) IS NULL
            OR meal_type NOT IN (N'B', N'L', N'D')
            OR TRY_CONVERT(INT, meal_count_text) IS NULL
            OR TRY_CONVERT(INT, meal_count_text) NOT BETWEEN 0 AND 9999
    )
        THROW 50370, N'직접입력 식사 수량 payload가 올바르지 않습니다.', 1;

    IF EXISTS
    (
        SELECT meal_date, meal_type
          FROM @RawManualCount
         GROUP BY meal_date, meal_type
        HAVING COUNT(*) <> 1
    )
        THROW 50373, N'직접입력 식사 수량 payload에 중복 항목이 있습니다.', 1;

    DECLARE @ManualCount TABLE
    (
        meal_date CHAR(8) NOT NULL,
        meal_type CHAR(1) NOT NULL,
        meal_count INT NOT NULL,
        PRIMARY KEY (meal_date, meal_type)
    );

    INSERT INTO @ManualCount (meal_date, meal_type, meal_count)
    SELECT CONVERT(CHAR(8), meal_date),
           CONVERT(CHAR(1), meal_type),
           TRY_CONVERT(INT, meal_count_text)
      FROM @RawManualCount;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        DECLARE @SubmissionSeq BIGINT;
        DECLARE @CurrentRevision INT;

        SELECT @SubmissionSeq = seq,
               @CurrentRevision = revision
          FROM dbo.meal_survey_submission WITH (UPDLOCK, HOLDLOCK)
         WHERE retreat = @RETREAT
           AND belong = @BELONG;

        SET @CurrentRevision = ISNULL(@CurrentRevision, 0);

        IF @CurrentRevision <> @EXPECTED_REVISION
        BEGIN
            COMMIT TRANSACTION;
            SELECT N'CONFLICT' AS result_code,
                   N'다른 사용자가 먼저 저장했습니다.' AS result_message,
                   @CurrentRevision AS submission_revision,
                   0 AS saved_count;
            RETURN;
        END;

        DECLARE @Effective TABLE
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
        INSERT INTO @Effective (meal_date, meal_type, provide_yn)
        SELECT CONVERT(CHAR(8), D.meal_dt, 112),
               M.meal_type,
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

        DECLARE @MemberCount INT;
        DECLARE @RosterList NVARCHAR(MAX);
        DECLARE @RosterHash CHAR(64);
        DECLARE @ConfigRevision INT;
        DECLARE @NewRevision INT = @CurrentRevision + 1;
        DECLARE @EntryMode CHAR(1);

        SELECT @MemberCount = COUNT(*),
               @RosterList = STRING_AGG(CONVERT(NVARCHAR(MAX), seq), N',')
                             WITHIN GROUP (ORDER BY seq)
          FROM dbo.group_members WITH (HOLDLOCK)
         WHERE retreat = @RETREAT
           AND belong = @BELONG;

        SET @EntryMode = CASE WHEN @MemberCount = 0 THEN 'M' ELSE 'P' END;

        IF @EntryMode = 'M' AND EXISTS (SELECT 1 FROM @Selection)
            THROW 50374, N'구성원이 없는 요회에는 개인별 식사 선택을 저장할 수 없습니다.', 1;

        IF @EntryMode = 'P' AND EXISTS (SELECT 1 FROM @ManualCount)
            THROW 50375, N'구성원이 등록된 요회에는 직접입력 식사 수량을 저장할 수 없습니다.', 1;

        IF @EntryMode = 'M'
           AND
           (
               EXISTS
               (
                   SELECT 1
                     FROM @ManualCount C
                    WHERE NOT EXISTS
                          (
                              SELECT 1
                                FROM @Effective E
                               WHERE E.meal_date = C.meal_date
                                 AND E.meal_type = C.meal_type
                                 AND E.provide_yn = 'Y'
                          )
               )
               OR EXISTS
               (
                   SELECT 1
                     FROM @Effective E
                    WHERE E.provide_yn = 'Y'
                      AND NOT EXISTS
                          (
                              SELECT 1
                                FROM @ManualCount C
                               WHERE C.meal_date = E.meal_date
                                 AND C.meal_type = E.meal_type
                          )
               )
           )
            THROW 50376, N'제공되는 모든 식사의 직접입력 수량이 필요합니다.', 1;

        IF EXISTS
        (
            SELECT 1
              FROM @Selection S
             WHERE NOT EXISTS
                   (
                       SELECT 1
                         FROM dbo.group_members M
                        WHERE M.seq = S.group_member_seq
                          AND M.retreat = @RETREAT
                          AND M.belong = @BELONG
                   )
        )
            THROW 50368, N'다른 요회 또는 유효하지 않은 구성원이 포함되어 있습니다.', 1;

        IF EXISTS
        (
            SELECT 1
              FROM @Selection S
             WHERE NOT EXISTS
                   (
                       SELECT 1
                         FROM @Effective E
                        WHERE E.meal_date = S.meal_date
                          AND E.meal_type = S.meal_type
                          AND E.provide_yn = 'Y'
                   )
        )
            THROW 50369, N'제공되지 않거나 기간 밖인 식사가 포함되어 있습니다.', 1;

        SET @RosterHash = CONVERT(CHAR(64), HASHBYTES('SHA2_256', ISNULL(@RosterList, N'')), 2);

        SELECT @ConfigRevision = ISNULL(MAX(config_revision), 0)
          FROM dbo.meal_service_config
         WHERE retreat = @RETREAT;

        IF @SubmissionSeq IS NULL
        BEGIN
            INSERT INTO dbo.meal_survey_submission
            (
                retreat,
                belong,
                revision,
                meal_config_revision,
                submitted_member_count,
                entry_mode,
                roster_hash,
                submitted_dt,
                browser_key_hash,
                ip_hash,
                ins_id,
                ins_ip,
                ins_dt
            )
            VALUES
            (
                @RETREAT,
                @BELONG,
                @NewRevision,
                @ConfigRevision,
                @MemberCount,
                @EntryMode,
                @RosterHash,
                SYSUTCDATETIME(),
                @BROWSER_KEY_HASH,
                @IP_HASH,
                @UID,
                @UIP,
                GETDATE()
            );

            SET @SubmissionSeq = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.meal_survey_submission
               SET revision = @NewRevision,
                   meal_config_revision = @ConfigRevision,
                   submitted_member_count = @MemberCount,
                   entry_mode = @EntryMode,
                   roster_hash = @RosterHash,
                   submitted_dt = SYSUTCDATETIME(),
                   browser_key_hash = @BROWSER_KEY_HASH,
                   ip_hash = @IP_HASH,
                   upt_id = @UID,
                   upt_ip = @UIP,
                   upt_dt = GETDATE()
             WHERE seq = @SubmissionSeq;
        END;

        DELETE FROM dbo.meal_survey_selection
         WHERE submission_seq = @SubmissionSeq;

        DELETE FROM dbo.meal_survey_manual_count
         WHERE submission_seq = @SubmissionSeq;

        DECLARE @SavedCount INT = 0;

        IF @EntryMode = 'P'
        BEGIN
            INSERT INTO dbo.meal_survey_selection
            (
                submission_seq,
                group_member_seq,
                meal_date,
                meal_type,
                ins_dt
            )
            SELECT @SubmissionSeq,
                   group_member_seq,
                   meal_date,
                   meal_type,
                   SYSUTCDATETIME()
              FROM @Selection;

            SET @SavedCount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.meal_survey_manual_count
            (
                submission_seq,
                meal_date,
                meal_type,
                meal_count,
                ins_dt
            )
            SELECT @SubmissionSeq,
                   meal_date,
                   meal_type,
                   meal_count,
                   SYSUTCDATETIME()
              FROM @ManualCount;

            SELECT @SavedCount = ISNULL(SUM(meal_count), 0)
              FROM @ManualCount;
        END;

        COMMIT TRANSACTION;

        SELECT N'SAVED' AS result_code,
               N'식사 여부를 저장했습니다.' AS result_message,
               @NewRevision AS submission_revision,
               @SavedCount AS saved_count;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
