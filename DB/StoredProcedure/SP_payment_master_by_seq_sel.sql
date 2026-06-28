CREATE OR ALTER PROCEDURE dbo.SP_payment_master_by_seq_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT cash_item_seq,
           file_path,
           file_url
      FROM ubfgj3.dbo.payment_master
     WHERE seq = @Seq;
END

