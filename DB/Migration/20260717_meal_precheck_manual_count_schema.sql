SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.meal_survey_submission', N'U') IS NULL
        THROW 50501, N'meal_survey_submission 테이블이 없습니다.', 1;

    IF COL_LENGTH(N'dbo.meal_survey_submission', N'entry_mode') IS NULL
    BEGIN
        ALTER TABLE dbo.meal_survey_submission
            ADD entry_mode CHAR(1) NOT NULL
                CONSTRAINT DF_meal_survey_submission_entry_mode DEFAULT ('P') WITH VALUES;
    END;

    IF NOT EXISTS
    (
        SELECT 1
          FROM sys.check_constraints
         WHERE parent_object_id = OBJECT_ID(N'dbo.meal_survey_submission')
           AND name = N'CK_meal_survey_submission_entry_mode'
    )
    BEGIN
        EXEC sys.sp_executesql N'
            ALTER TABLE dbo.meal_survey_submission WITH CHECK
                ADD CONSTRAINT CK_meal_survey_submission_entry_mode
                    CHECK (entry_mode IN (''P'', ''M''));';
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

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
