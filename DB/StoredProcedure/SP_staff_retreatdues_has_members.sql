CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_has_members]
    @retreat INT,
    @dues_seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq
    FROM ubfgj3.dbo.group_members
    WHERE retreat = @retreat
      AND duestype = (
          SELECT seq
          FROM ubfgj3.dbo.retreatdues_master
          WHERE seq = @dues_seq
      );
END
