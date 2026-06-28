CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_insert]
    @retreat INT,
    @dues_nm NVARCHAR(200),
    @dues DECIMAL(18, 0),
    @dues_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.retreatdues_master (
        retreat,
        dues_nm,
        dues,
        dues_desc,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        @retreat,
        @dues_nm,
        @dues,
        @dues_desc,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END
