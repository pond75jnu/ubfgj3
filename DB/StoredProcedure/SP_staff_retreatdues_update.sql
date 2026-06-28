CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_update]
    @seq INT,
    @retreat INT,
    @dues_nm NVARCHAR(200),
    @dues DECIMAL(18, 0),
    @dues_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.retreatdues_master
    SET retreat = @retreat,
        dues_nm = @dues_nm,
        dues = @dues,
        dues_desc = @dues_desc,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END
