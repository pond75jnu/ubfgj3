CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.cash_item_master
    WHERE seq = @seq;
END
