CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_insert]
    @cash_type INT,
    @item_nm NVARCHAR(200),
    @item_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.cash_item_master (
        retreat,
        cash_type,
        item_nm,
        item_desc,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        1,
        @cash_type,
        @item_nm,
        @item_desc,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END
