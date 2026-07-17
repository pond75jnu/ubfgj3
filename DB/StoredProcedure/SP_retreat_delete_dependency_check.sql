CREATE OR ALTER PROCEDURE dbo.SP_retreat_delete_dependency_check
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CONVERT(BIGINT, seq) AS seq
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @SEQ
    UNION ALL
    SELECT CONVERT(BIGINT, seq)
      FROM ubfgj3.dbo.retreatdues_master
     WHERE retreat = @SEQ
    UNION ALL
    SELECT CONVERT(BIGINT, seq)
      FROM ubfgj3.dbo.meal_service_config
     WHERE retreat = @SEQ
    UNION ALL
    SELECT seq
      FROM ubfgj3.dbo.meal_survey_submission
     WHERE retreat = @SEQ;
END
