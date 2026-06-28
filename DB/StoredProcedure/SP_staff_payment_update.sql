CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_update]
    @seq INT,
    @retreat INT,
    @cash_item_seq INT,
    @payment_dt VARCHAR(8),
    @payment_item NVARCHAR(200),
    @payment DECIMAL(18, 0),
    @payment_item_desc NVARCHAR(MAX),
    @del_file_yn CHAR(1),
    @file_nm NVARCHAR(100),
    @file_type NVARCHAR(20),
    @file_url NVARCHAR(500),
    @file_path NVARCHAR(1000),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.payment_master
    SET retreat = @retreat,
        cash_item_seq = @cash_item_seq,
        payment_dt = @payment_dt,
        payment_item = @payment_item,
        payment = @payment,
        payment_item_desc = @payment_item_desc,
        file_nm = CASE WHEN @del_file_yn = 'Y' THEN N''
                       WHEN @del_file_yn = 'A' THEN @file_nm
                       ELSE file_nm END,
        file_type = CASE WHEN @del_file_yn = 'Y' THEN N''
                         WHEN @del_file_yn = 'A' THEN @file_type
                         ELSE file_type END,
        file_url = CASE WHEN @del_file_yn = 'Y' THEN N''
                        WHEN @del_file_yn = 'A' THEN @file_url
                        ELSE file_url END,
        file_path = CASE WHEN @del_file_yn = 'Y' THEN N''
                         WHEN @del_file_yn = 'A' THEN @file_path
                         ELSE file_path END,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END
