CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_upd]
    @Seq INT,
    @BelongNm NVARCHAR(200),
    @Manager NVARCHAR(100),
    @UseYn CHAR(1),
    @LoginId NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.[groups]
       SET belong_nm = @BelongNm,
           manager = @Manager,
           etc1 = @UseYn,
           upt_id = @LoginId,
           upt_ip = @UserIp,
           upt_dt = GETDATE()
     WHERE seq = @Seq;
END
GO
