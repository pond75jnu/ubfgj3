SET NOCOUNT ON;

IF COL_LENGTH(N'dbo.meal_survey_submission', N'entry_mode') IS NULL
    THROW 50511, N'meal_survey_submission.entry_mode 컬럼이 없습니다.', 1;

IF OBJECT_ID(N'dbo.meal_survey_manual_count', N'U') IS NULL
    THROW 50512, N'meal_survey_manual_count 테이블이 없습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_submission
     WHERE entry_mode NOT IN ('P', 'M')
)
    THROW 50513, N'유효하지 않은 식사 제출 입력 방식이 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_manual_count C
      LEFT JOIN dbo.meal_survey_submission H ON H.seq = C.submission_seq
     WHERE H.seq IS NULL
)
    THROW 50514, N'고아 직접입력 식사 수량 데이터가 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_manual_count C
     INNER JOIN dbo.meal_survey_submission H ON H.seq = C.submission_seq
     WHERE H.entry_mode <> 'M'
)
    THROW 50515, N'개인 선택 제출에 직접입력 식사 수량이 연결되어 있습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.meal_survey_selection S
     INNER JOIN dbo.meal_survey_submission H ON H.seq = S.submission_seq
     WHERE H.entry_mode <> 'P'
)
    THROW 50516, N'직접입력 제출에 개인 식사 선택이 연결되어 있습니다.', 1;

SELECT N'OK' AS result_code,
       (SELECT COUNT(*) FROM dbo.meal_survey_submission WHERE entry_mode = 'M') AS manual_submission_count,
       (SELECT COUNT(*) FROM dbo.meal_survey_manual_count) AS manual_count_row_count,
       (SELECT ISNULL(SUM(meal_count), 0) FROM dbo.meal_survey_manual_count) AS manual_portion_count;
