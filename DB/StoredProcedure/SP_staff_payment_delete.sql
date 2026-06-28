CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.payment_master
    WHERE seq = @seq;
END
