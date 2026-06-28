CREATE OR ALTER PROCEDURE dbo.SP_payment_print_detail_get
    @SEQ INT,
    @CASH_TYPE INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.retreat,
           A.cash_item_seq,
           B.item_nm,
           SUBSTRING(A.payment_dt, 1, 4) + '-' + SUBSTRING(A.payment_dt, 5, 2) + '-' + SUBSTRING(A.payment_dt, 7, 2) AS payment_dt,
           A.payment_item,
           A.payment,
           FORMAT(A.payment, N'#,0') + N' 원' AS payment_format,
           A.payment_item_desc,
           A.file_nm,
           A.file_type,
           A.file_url,
           A.file_path
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.seq = @SEQ
       AND B.cash_type = @CASH_TYPE;
END

