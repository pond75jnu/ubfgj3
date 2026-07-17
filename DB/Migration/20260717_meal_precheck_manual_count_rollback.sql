SET XACT_ABORT ON;
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.meal_survey_manual_count', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.meal_survey_manual_count)
    THROW 50521, N'직접입력 식사 수량 데이터가 있어 rollback할 수 없습니다.', 1;

IF COL_LENGTH(N'dbo.meal_survey_submission', N'entry_mode') IS NOT NULL
BEGIN
    DECLARE @ManualSubmissionCount INT;
    EXEC sys.sp_executesql
        N'SELECT @Count = COUNT(*) FROM dbo.meal_survey_submission WHERE entry_mode = ''M'';',
        N'@Count INT OUTPUT',
        @Count = @ManualSubmissionCount OUTPUT;
    IF @ManualSubmissionCount > 0
        THROW 50522, N'직접입력 방식의 식사 제출이 있어 rollback할 수 없습니다.', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    DROP TABLE IF EXISTS dbo.meal_survey_manual_count;

    IF EXISTS
    (
        SELECT 1
          FROM sys.check_constraints
         WHERE parent_object_id = OBJECT_ID(N'dbo.meal_survey_submission')
           AND name = N'CK_meal_survey_submission_entry_mode'
    )
        ALTER TABLE dbo.meal_survey_submission
            DROP CONSTRAINT CK_meal_survey_submission_entry_mode;

    IF EXISTS
    (
        SELECT 1
          FROM sys.default_constraints
         WHERE parent_object_id = OBJECT_ID(N'dbo.meal_survey_submission')
           AND name = N'DF_meal_survey_submission_entry_mode'
    )
        ALTER TABLE dbo.meal_survey_submission
            DROP CONSTRAINT DF_meal_survey_submission_entry_mode;

    IF COL_LENGTH(N'dbo.meal_survey_submission', N'entry_mode') IS NOT NULL
        EXEC sys.sp_executesql N'ALTER TABLE dbo.meal_survey_submission DROP COLUMN entry_mode;';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
