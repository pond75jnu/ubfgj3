CREATE OR ALTER PROCEDURE dbo.SP_payment_expenses_summary_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(A.payment) AS cnt,
           SUM(A.payment) AS total_payment,
           FORMAT(SUM(A.payment), N'#,0') + N' 원' AS total_payment_format
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.retreat = @Retreat
       AND B.cash_type = 2;
END
