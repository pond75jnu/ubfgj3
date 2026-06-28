CREATE OR ALTER PROCEDURE [dbo].[SP_member_email_duplicate_sel]
    @Email NVARCHAR(256),
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT email
      FROM ubfgj3.dbo.member_master
     WHERE LOWER(email) = LOWER(@Email)
       AND LOWER(login_id) <> LOWER(@LoginId);
END
GO
