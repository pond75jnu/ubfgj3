CREATE OR ALTER PROCEDURE dbo.SP_member_master_by_login_sel
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT kor_nm,
           belong,
           belong_nm
      FROM ubfgj3.dbo.member_master
     WHERE LOWER(login_id) = LOWER(@LoginId);
END

