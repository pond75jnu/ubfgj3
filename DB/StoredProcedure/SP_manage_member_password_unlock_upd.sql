CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_password_unlock_upd]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE B
       SET IsLockedOut = 0,
           FailedPasswordAttemptCount = 0,
           Comment = '0'
      FROM ubfgj3.dbo.aspnet_Membership B
     INNER JOIN ubfgj3.dbo.aspnet_Users A ON A.UserId = B.UserId
     WHERE LOWER(A.UserName) = LOWER(@LoginId);
END
GO
