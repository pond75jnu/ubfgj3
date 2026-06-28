CREATE OR ALTER PROCEDURE [dbo].[SP_member_detail_sel]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.UserName AS login_id,
           C.kor_nm,
           C.email,
           D.seq AS belong_code,
           D.belong_nm + N' 요회' AS belong_nm,
           F.LoweredRoleName AS user_type,
           F.Description AS user_type_nm,
           B.IsApproved,
           CASE WHEN B.IsApproved = 1 THEN '1' ELSE '0' END AS IsApproved_code,
           CASE WHEN B.IsApproved = 1 THEN N'사용중' ELSE N'계정잠금' END AS IsApproved_nm
      FROM ubfgj3.dbo.aspnet_Users A
     INNER JOIN ubfgj3.dbo.aspnet_Membership B ON B.UserId = A.UserId
     INNER JOIN ubfgj3.dbo.member_master C ON LOWER(C.login_id) = LOWER(A.UserName)
     INNER JOIN ubfgj3.dbo.[groups] D ON D.seq = C.belong
     INNER JOIN ubfgj3.dbo.aspnet_UsersInRoles E ON E.UserId = A.UserId
     INNER JOIN ubfgj3.dbo.aspnet_Roles F ON F.RoleId = E.RoleId
     WHERE LOWER(A.UserName) = LOWER(@LoginId);
END
GO
