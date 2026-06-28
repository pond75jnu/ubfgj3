CREATE OR ALTER PROCEDURE [dbo].[SP_member_find_id_sel]
    @KorNm NVARCHAR(100),
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT login_id
      FROM ubfgj3.dbo.member_master
     WHERE kor_nm = @KorNm
       AND LOWER(email) = LOWER(@Email);
END
GO
