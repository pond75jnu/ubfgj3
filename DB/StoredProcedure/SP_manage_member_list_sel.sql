CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_list_sel]
    @SearchName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER (ORDER BY B.IsApproved, F.RoleName, D.belong_nm, C.kor_nm) AS num,
           A.UserName AS login_id,
           C.kor_nm,
           C.email,
           D.belong_nm + N' 요회' AS belong_nm,
           F.Description AS user_type,
           CASE WHEN B.IsApproved = 1 THEN N'사용중' ELSE N'계정잠금' END AS IsApproved
      FROM ubfgj3.dbo.aspnet_Users A
     INNER JOIN ubfgj3.dbo.aspnet_Membership B ON B.UserId = A.UserId
     INNER JOIN ubfgj3.dbo.member_master C ON LOWER(C.login_id) = LOWER(A.UserName)
     INNER JOIN ubfgj3.dbo.[groups] D ON D.seq = C.belong
     INNER JOIN ubfgj3.dbo.aspnet_UsersInRoles E ON E.UserId = A.UserId
     INNER JOIN ubfgj3.dbo.aspnet_Roles F ON F.RoleId = E.RoleId
     WHERE C.kor_nm LIKE N'%' + @SearchName + N'%';
END
GO
