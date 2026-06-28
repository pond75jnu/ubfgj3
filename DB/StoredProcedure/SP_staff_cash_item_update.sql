CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_update]
    @seq INT,
    @cash_type INT,
    @item_nm NVARCHAR(200),
    @item_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.cash_item_master
    SET retreat = 1,
        cash_type = @cash_type,
        item_nm = @item_nm,
        item_desc = @item_desc,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END
