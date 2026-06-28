CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_get_list]
    @retreat INT,
    @cash_type INT,
    @excel_yn CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    EXEC ubfgj3.dbo.SP_income_get_list @retreat, @cash_type, @excel_yn;
END
