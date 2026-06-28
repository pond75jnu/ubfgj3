CREATE OR ALTER PROCEDURE [dbo].[SP_member_master_ins]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @BelongNm NVARCHAR(200),
    @Email NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.member_master
        (login_id, kor_nm, belong, belong_nm, email, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt)
    VALUES
        (@LoginId, @KorNm, @Belong, @BelongNm, @Email, @LoginId, @UserIp, GETDATE(), @LoginId, @UserIp, GETDATE());
END
GO
