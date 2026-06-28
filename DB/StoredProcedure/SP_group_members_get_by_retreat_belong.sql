CREATE OR ALTER PROCEDURE dbo.SP_group_members_get_by_retreat_belong
    @RETREAT INT,
    @BELONG INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.*
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.groups B ON B.retreat = A.retreat
                                   AND B.seq = A.belong
     WHERE A.belong = @BELONG
       AND A.retreat = @RETREAT;
END

