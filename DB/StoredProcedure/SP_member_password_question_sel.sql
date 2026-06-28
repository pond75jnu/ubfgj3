CREATE OR ALTER PROCEDURE [dbo].[SP_member_password_question_sel]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT B.PasswordQuestion
      FROM ubfgj3.dbo.aspnet_Users A
     INNER JOIN ubfgj3.dbo.aspnet_Membership B ON B.UserId = A.UserId
     WHERE LOWER(A.UserName) = LOWER(@LoginId);
END
GO
