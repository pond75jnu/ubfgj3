CREATE OR ALTER PROCEDURE [dbo].[SP_member_join_email_check_sel]
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LoweredEmail
      FROM ubfgj3.dbo.aspnet_Membership
     WHERE LoweredEmail = LOWER(@Email);
END
GO
