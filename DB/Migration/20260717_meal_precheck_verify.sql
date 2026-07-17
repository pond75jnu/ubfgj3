SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.meal_service_config', N'U') IS NULL
    THROW 50101, N'meal_service_config 테이블이 없습니다.', 1;
IF OBJECT_ID(N'dbo.meal_survey_submission', N'U') IS NULL
    THROW 50102, N'meal_survey_submission 테이블이 없습니다.', 1;
IF OBJECT_ID(N'dbo.meal_survey_selection', N'U') IS NULL
    THROW 50103, N'meal_survey_selection 테이블이 없습니다.', 1;
IF OBJECT_ID(N'dbo.meal_survey_manual_count', N'U') IS NULL
    THROW 50111, N'meal_survey_manual_count 테이블이 없습니다.', 1;
IF OBJECT_ID(N'dbo.meal_access_guard', N'U') IS NULL
    THROW 50104, N'meal_access_guard 테이블이 없습니다.', 1;
IF COL_LENGTH(N'dbo.meal_survey_submission', N'entry_mode') IS NULL
    THROW 50112, N'meal_survey_submission.entry_mode 컬럼이 없습니다.', 1;

DECLARE @RequiredProcedures TABLE (procedure_name SYSNAME PRIMARY KEY);
INSERT INTO @RequiredProcedures (procedure_name)
VALUES
    (N'SP_meal_service_effective_get'),
    (N'SP_meal_service_save'),
    (N'SP_meal_survey_groups_get'),
    (N'SP_meal_survey_members_get'),
    (N'SP_meal_survey_save'),
    (N'SP_meal_summary_get'),
    (N'SP_meal_group_detail_get'),
    (N'SP_meal_access_guard_get'),
    (N'SP_meal_access_failure_record'),
    (N'SP_meal_access_success_try'),
    (N'SP_group_members_delete_missing'),
    (N'SP_group_members_delete_by_group'),
    (N'SP_manage_group_del'),
    (N'SP_retreat_delete_dependency_check');

IF EXISTS
(
    SELECT 1
      FROM @RequiredProcedures R
     WHERE OBJECT_ID(N'dbo.' + R.procedure_name, N'P') IS NULL
)
    THROW 50105, N'필수 Stored Procedure가 누락되었습니다.', 1;

IF (SELECT COUNT(*)
      FROM dbo.menu_master
     WHERE LOWER(ISNULL(menu_path, '')) = '/staff/mealstatus.aspx'
       AND menu_auth = 'manager'
       AND menu_depth = 1) <> 1
    THROW 50106, N'식사수량파악 메뉴 설정이 올바르지 않습니다.', 1;

IF EXISTS
(
    SELECT retreat
      FROM dbo.meal_service_config
     GROUP BY retreat
    HAVING MIN(config_revision) <> MAX(config_revision)
)
    THROW 50107, N'한 수양회의 식사 설정 revision이 일치하지 않습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_selection S
      LEFT JOIN dbo.meal_survey_submission H ON H.seq = S.submission_seq
     WHERE H.seq IS NULL
)
    THROW 50108, N'고아 식사 선택 데이터가 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_submission H
      LEFT JOIN dbo.groups G ON G.seq = H.belong AND G.retreat = H.retreat
     WHERE G.seq IS NULL
)
    THROW 50109, N'유효하지 않은 요회의 식사 제출 데이터가 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_selection S
      LEFT JOIN dbo.group_members M ON M.seq = S.group_member_seq
     WHERE M.seq IS NULL
)
    THROW 50110, N'유효하지 않은 구성원의 식사 선택 데이터가 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_manual_count C
      LEFT JOIN dbo.meal_survey_submission H ON H.seq = C.submission_seq
     WHERE H.seq IS NULL
)
    THROW 50113, N'고아 직접입력 식사 수량 데이터가 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_manual_count C
     INNER JOIN dbo.meal_survey_submission H ON H.seq = C.submission_seq
     WHERE H.entry_mode <> 'M'
)
    THROW 50114, N'직접입력 식사 수량과 제출 입력 방식이 일치하지 않습니다.', 1;

SELECT N'OK' AS result_code,
       (SELECT COUNT(*) FROM dbo.meal_service_config) AS config_count,
       (SELECT COUNT(*) FROM dbo.meal_survey_submission) AS submission_count,
       (SELECT COUNT(*) FROM dbo.meal_survey_selection) AS selection_count,
       (SELECT COUNT(*) FROM dbo.meal_survey_manual_count) AS manual_count_row_count,
       (SELECT COUNT(*) FROM dbo.meal_access_guard) AS guard_count;
