CREATE OR ALTER PROCEDURE dbo.SP_retreat_delete_dependency_check
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @SEQ
    UNION ALL
    SELECT seq
      FROM ubfgj3.dbo.retreatdues_master
     WHERE retreat = @SEQ;
END

