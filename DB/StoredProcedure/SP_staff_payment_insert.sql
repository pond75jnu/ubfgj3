CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_insert]
    @retreat INT,
    @cash_item_seq INT,
    @payment_dt VARCHAR(8),
    @payment_item NVARCHAR(200),
    @payment DECIMAL(18, 0),
    @payment_item_desc NVARCHAR(MAX),
    @file_nm NVARCHAR(100),
    @file_type NVARCHAR(20),
    @file_url NVARCHAR(500),
    @file_path NVARCHAR(1000),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.payment_master (
        retreat,
        cash_item_seq,
        payment_dt,
        payment_item,
        payment,
        payment_item_desc,
        file_nm,
        file_type,
        file_url,
        file_path,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        @retreat,
        @cash_item_seq,
        @payment_dt,
        @payment_item,
        @payment,
        @payment_item_desc,
        @file_nm,
        @file_type,
        @file_url,
        @file_path,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END
