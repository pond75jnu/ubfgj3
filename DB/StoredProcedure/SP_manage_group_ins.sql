CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_ins]
    @BelongNm NVARCHAR(200),
    @Manager NVARCHAR(100),
    @Retreat INT,
    @UseYn CHAR(1),
    @LoginId NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.[groups]
        (belong_nm, manager, retreat, etc1, etc2, etc3, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt)
    VALUES
        (@BelongNm, @Manager, @Retreat, @UseYn, NULL, NULL, @LoginId, @UserIp, GETDATE(), @LoginId, @UserIp, GETDATE());
END
GO
