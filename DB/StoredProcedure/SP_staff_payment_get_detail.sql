CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_get_detail]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           cash_item_seq,
           SUBSTRING(payment_dt, 1, 4) + '-' + SUBSTRING(payment_dt, 5, 2) + '-' + SUBSTRING(payment_dt, 7, 2) AS payment_dt,
           payment_item,
           payment,
           FORMAT(payment, N'#,0') AS payment_format_comma,
           payment_item_desc,
           file_nm,
           file_type,
           file_url,
           file_path
    FROM ubfgj3.dbo.payment_master
    WHERE seq = @seq;
END
