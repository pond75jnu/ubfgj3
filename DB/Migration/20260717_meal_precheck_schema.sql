SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.meal_service_config', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.meal_service_config
        (
            seq INT IDENTITY(1, 1) NOT NULL
                CONSTRAINT PK_meal_service_config PRIMARY KEY,
            retreat INT NOT NULL,
            meal_date CHAR(8) NOT NULL,
            meal_type CHAR(1) NOT NULL,
            provide_yn CHAR(1) NOT NULL,
            config_revision INT NOT NULL,
            ins_id NVARCHAR(50) NULL,
            ins_ip NVARCHAR(100) NULL,
            ins_dt DATETIME NOT NULL
                CONSTRAINT DF_meal_service_config_ins_dt DEFAULT (GETDATE()),
            upt_id NVARCHAR(50) NULL,
            upt_ip NVARCHAR(100) NULL,
            upt_dt DATETIME NULL,
            CONSTRAINT UQ_meal_service_config_retreat_date_type
                UNIQUE (retreat, meal_date, meal_type),
            CONSTRAINT CK_meal_service_config_meal_type
                CHECK (meal_type IN ('B', 'L', 'D')),
            CONSTRAINT CK_meal_service_config_provide_yn
                CHECK (provide_yn IN ('Y', 'N')),
            CONSTRAINT CK_meal_service_config_meal_date
                CHECK (LEN(meal_date) = 8 AND meal_date NOT LIKE '%[^0-9]%'),
            CONSTRAINT CK_meal_service_config_revision
                CHECK (config_revision >= 1)
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_service_config')
           AND name = N'IX_meal_service_config_lookup'
    )
    BEGIN
        CREATE INDEX IX_meal_service_config_lookup
            ON dbo.meal_service_config (retreat, provide_yn, meal_date, meal_type);
    END;

    IF OBJECT_ID(N'dbo.meal_survey_submission', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.meal_survey_submission
        (
            seq BIGINT IDENTITY(1, 1) NOT NULL
                CONSTRAINT PK_meal_survey_submission PRIMARY KEY,
            retreat INT NOT NULL,
            belong INT NOT NULL,
            revision INT NOT NULL,
            meal_config_revision INT NOT NULL,
            submitted_member_count INT NOT NULL,
            entry_mode CHAR(1) NOT NULL
                CONSTRAINT DF_meal_survey_submission_entry_mode DEFAULT ('P'),
            roster_hash CHAR(64) NOT NULL,
            submitted_dt DATETIME2(0) NOT NULL,
            browser_key_hash CHAR(64) NULL,
            ip_hash CHAR(64) NULL,
            ins_id NVARCHAR(50) NULL,
            ins_ip NVARCHAR(100) NULL,
            ins_dt DATETIME NOT NULL
                CONSTRAINT DF_meal_survey_submission_ins_dt DEFAULT (GETDATE()),
            upt_id NVARCHAR(50) NULL,
            upt_ip NVARCHAR(100) NULL,
            upt_dt DATETIME NULL,
            CONSTRAINT UQ_meal_survey_submission_retreat_belong
                UNIQUE (retreat, belong),
            CONSTRAINT CK_meal_survey_submission_revision
                CHECK (revision >= 1),
            CONSTRAINT CK_meal_survey_submission_config_revision
                CHECK (meal_config_revision >= 0),
            CONSTRAINT CK_meal_survey_submission_member_count
                CHECK (submitted_member_count >= 0),
            CONSTRAINT CK_meal_survey_submission_entry_mode
                CHECK (entry_mode IN ('P', 'M'))
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_survey_submission')
           AND name = N'IX_meal_survey_submission_retreat_submitted'
    )
    BEGIN
        CREATE INDEX IX_meal_survey_submission_retreat_submitted
            ON dbo.meal_survey_submission (retreat, submitted_dt);
    END;

    IF OBJECT_ID(N'dbo.meal_survey_selection', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.meal_survey_selection
        (
            seq BIGINT IDENTITY(1, 1) NOT NULL
                CONSTRAINT PK_meal_survey_selection PRIMARY KEY,
            submission_seq BIGINT NOT NULL,
            group_member_seq INT NOT NULL,
            meal_date CHAR(8) NOT NULL,
            meal_type CHAR(1) NOT NULL,
            ins_dt DATETIME2(0) NOT NULL
                CONSTRAINT DF_meal_survey_selection_ins_dt DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT FK_meal_survey_selection_submission
                FOREIGN KEY (submission_seq)
                REFERENCES dbo.meal_survey_submission (seq)
                ON DELETE CASCADE,
            CONSTRAINT UQ_meal_survey_selection_submission_member_date_type
                UNIQUE (submission_seq, group_member_seq, meal_date, meal_type),
            CONSTRAINT CK_meal_survey_selection_meal_type
                CHECK (meal_type IN ('B', 'L', 'D')),
            CONSTRAINT CK_meal_survey_selection_meal_date
                CHECK (LEN(meal_date) = 8 AND meal_date NOT LIKE '%[^0-9]%')
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_survey_selection')
           AND name = N'IX_meal_survey_selection_summary'
    )
    BEGIN
        CREATE INDEX IX_meal_survey_selection_summary
            ON dbo.meal_survey_selection (submission_seq, meal_date, meal_type)
            INCLUDE (group_member_seq);
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_survey_selection')
           AND name = N'IX_meal_survey_selection_member'
    )
    BEGIN
        CREATE INDEX IX_meal_survey_selection_member
            ON dbo.meal_survey_selection (group_member_seq);
    END;

    IF OBJECT_ID(N'dbo.meal_survey_manual_count', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.meal_survey_manual_count
        (
            seq BIGINT IDENTITY(1, 1) NOT NULL
                CONSTRAINT PK_meal_survey_manual_count PRIMARY KEY,
            submission_seq BIGINT NOT NULL,
            meal_date CHAR(8) NOT NULL,
            meal_type CHAR(1) NOT NULL,
            meal_count INT NOT NULL,
            ins_dt DATETIME2(0) NOT NULL
                CONSTRAINT DF_meal_survey_manual_count_ins_dt DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT FK_meal_survey_manual_count_submission
                FOREIGN KEY (submission_seq)
                REFERENCES dbo.meal_survey_submission (seq)
                ON DELETE CASCADE,
            CONSTRAINT UQ_meal_survey_manual_count_submission_date_type
                UNIQUE (submission_seq, meal_date, meal_type),
            CONSTRAINT CK_meal_survey_manual_count_meal_type
                CHECK (meal_type IN ('B', 'L', 'D')),
            CONSTRAINT CK_meal_survey_manual_count_meal_date
                CHECK (LEN(meal_date) = 8 AND meal_date NOT LIKE '%[^0-9]%'),
            CONSTRAINT CK_meal_survey_manual_count_count
                CHECK (meal_count BETWEEN 0 AND 9999)
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_survey_manual_count')
           AND name = N'IX_meal_survey_manual_count_summary'
    )
    BEGIN
        CREATE INDEX IX_meal_survey_manual_count_summary
            ON dbo.meal_survey_manual_count (submission_seq, meal_date, meal_type)
            INCLUDE (meal_count);
    END;

    IF OBJECT_ID(N'dbo.meal_access_guard', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.meal_access_guard
        (
            seq BIGINT IDENTITY(1, 1) NOT NULL
                CONSTRAINT PK_meal_access_guard PRIMARY KEY,
            scope_type CHAR(1) NOT NULL,
            scope_hash CHAR(64) NOT NULL,
            failed_count INT NOT NULL
                CONSTRAINT DF_meal_access_guard_failed_count DEFAULT (0),
            window_started_at DATETIME2(0) NOT NULL,
            last_failed_at DATETIME2(0) NULL,
            locked_until DATETIME2(0) NULL,
            upt_dt DATETIME2(0) NOT NULL,
            CONSTRAINT UQ_meal_access_guard_scope
                UNIQUE (scope_type, scope_hash),
            CONSTRAINT CK_meal_access_guard_scope_type
                CHECK (scope_type IN ('B', 'I')),
            CONSTRAINT CK_meal_access_guard_failed_count
                CHECK (failed_count >= 0)
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.indexes
         WHERE object_id = OBJECT_ID(N'dbo.meal_access_guard')
           AND name = N'IX_meal_access_guard_locked_until'
    )
    BEGIN
        CREATE INDEX IX_meal_access_guard_locked_until
            ON dbo.meal_access_guard (locked_until);
    END;

    DECLARE @StaffMenuSeq INT;
    DECLARE @StaffMenuCount INT;

    SELECT @StaffMenuSeq = MIN(seq),
           @StaffMenuCount = COUNT(*)
      FROM dbo.menu_master
     WHERE menu_depth = 0
       AND menu_nm = N'실무자';

    IF @StaffMenuCount <> 1
        THROW 50001, N'실무자 상위 메뉴를 정확히 한 건 찾을 수 없습니다.', 1;

    IF EXISTS
    (
        SELECT 1
          FROM dbo.menu_master
         WHERE LOWER(ISNULL(menu_path, '')) = '/staff/mealstatus.aspx'
    )
    BEGIN
        UPDATE dbo.menu_master
           SET parent_seq = @StaffMenuSeq,
               menu_nm = N'식사수량파악',
               menu_depth = 1,
               menu_order = 5,
               menu_auth = 'manager'
         WHERE LOWER(ISNULL(menu_path, '')) = '/staff/mealstatus.aspx';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.menu_master
        (
            parent_seq,
            menu_nm,
            menu_path,
            menu_depth,
            menu_order,
            menu_auth
        )
        VALUES
        (
            @StaffMenuSeq,
            N'식사수량파악',
            '/staff/mealstatus.aspx',
            1,
            5,
            'manager'
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
