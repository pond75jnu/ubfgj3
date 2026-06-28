CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_has_payments]
    @cash_item_seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq
    FROM ubfgj3.dbo.payment_master
    WHERE cash_item_seq = @cash_item_seq;
END
