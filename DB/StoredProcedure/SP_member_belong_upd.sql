CREATE OR ALTER PROCEDURE dbo.SP_member_belong_upd
    @LoginId NVARCHAR(256),
    @Belong INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.member_master
       SET belong = @Belong
     WHERE LOWER(login_id) = LOWER(@LoginId);
END

