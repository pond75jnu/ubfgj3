CREATE OR ALTER PROCEDURE dbo.SP_income_summary_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(seq) AS cnt,
           SUM(user_dues) AS total_regist,
           FORMAT(SUM(user_dues), N'#,0') + N' 원' AS total_regist_format
      FROM ubfgj3.dbo.group_members
     WHERE ISNULL(manager_confirm, '') = 'Y'
       AND user_dues > 0
       AND retreat = @Retreat;

    SELECT COUNT(A.payment) AS cnt,
           SUM(A.payment) AS total_payment,
           FORMAT(SUM(A.payment), N'#,0') + N' 원' AS total_payment_format
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.retreat = @Retreat
       AND B.cash_type = 1;
END
