SET NOCOUNT ON;

IF COL_LENGTH(N'dbo.group_members', N'gender') IS NULL
    THROW 50001, N'group_members.gender 컬럼이 없습니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM sys.columns
     WHERE object_id = OBJECT_ID(N'dbo.group_members')
       AND name = N'gender'
       AND (TYPE_NAME(user_type_id) <> N'char' OR max_length <> 1 OR is_nullable <> 1)
)
    THROW 50002, N'group_members.gender 컬럼 정의가 CHAR(1) NULL이 아닙니다.', 1;

IF NOT EXISTS
(
    SELECT 1
      FROM sys.check_constraints
     WHERE parent_object_id = OBJECT_ID(N'dbo.group_members')
       AND name = N'CK_group_members_gender'
       AND is_disabled = 0
       AND is_not_trusted = 0
)
    THROW 50003, N'성별 체크 제약조건이 없거나 활성 상태가 아닙니다.', 1;

IF EXISTS
(
    SELECT 1
      FROM dbo.group_members
     WHERE gender IS NOT NULL
       AND gender NOT IN ('M', 'F')
)
    THROW 50004, N'허용되지 않은 성별 값이 있습니다.', 1;

SELECT N'OK' AS verification_result;
