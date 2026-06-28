CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.retreatdues_master
    WHERE seq = @seq;
END
