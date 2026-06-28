CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_get_detail]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           dues_nm,
           dues,
           dues_desc
    FROM ubfgj3.dbo.retreatdues_master
    WHERE seq = @seq;
END
