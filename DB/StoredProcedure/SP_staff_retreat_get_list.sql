CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreat_get_list]
    @top_count INT,
    @active_only BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top_count) seq, retreat_name
    FROM ubfgj3.dbo.retreat_master
    WHERE (@active_only = 0 OR ISNULL(retreat_yn, 'N') = 'Y')
    ORDER BY seq DESC;
END
