SET XACT_ABORT ON;
SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM dbo.meal_survey_selection)
    THROW 50201, N'식사 선택 데이터가 있어 rollback할 수 없습니다.', 1;
IF OBJECT_ID(N'dbo.meal_survey_manual_count', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.meal_survey_manual_count)
    THROW 50204, N'직접입력 식사 수량 데이터가 있어 rollback할 수 없습니다.', 1;
IF EXISTS (SELECT 1 FROM dbo.meal_survey_submission)
    THROW 50202, N'식사 제출 데이터가 있어 rollback할 수 없습니다.', 1;
IF EXISTS (SELECT 1 FROM dbo.meal_service_config)
    THROW 50203, N'식사 설정 데이터가 있어 rollback할 수 없습니다.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM dbo.menu_master
     WHERE LOWER(ISNULL(menu_path, '')) = '/staff/mealstatus.aspx';

    DROP PROCEDURE IF EXISTS dbo.SP_meal_service_effective_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_service_save;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_survey_groups_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_survey_members_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_survey_save;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_summary_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_group_detail_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_access_guard_get;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_access_failure_record;
    DROP PROCEDURE IF EXISTS dbo.SP_meal_access_success_try;

    DROP TABLE IF EXISTS dbo.meal_survey_selection;
    DROP TABLE IF EXISTS dbo.meal_survey_manual_count;
    DROP TABLE IF EXISTS dbo.meal_survey_submission;
    DROP TABLE IF EXISTS dbo.meal_service_config;
    DROP TABLE IF EXISTS dbo.meal_access_guard;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
