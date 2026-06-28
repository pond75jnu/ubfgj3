CREATE OR ALTER PROCEDURE [dbo].[SP_member_profile_upd]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@LoginId);

    BEGIN TRANSACTION;

    UPDATE ubfgj3.dbo.aspnet_Membership
       SET Email = @Email,
           LoweredEmail = LOWER(@Email)
     WHERE UserId = @UserId;

    UPDATE ubfgj3.dbo.member_master
       SET kor_nm = @KorNm,
           belong = @Belong,
           email = @Email
     WHERE LOWER(login_id) = LOWER(@LoginId);

    COMMIT TRANSACTION;
END
GO
