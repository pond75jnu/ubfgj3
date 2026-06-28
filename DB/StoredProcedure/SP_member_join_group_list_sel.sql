CREATE OR ALTER PROCEDURE [dbo].[SP_member_join_group_list_sel]
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           CASE WHEN belong_nm LIKE N'%센터' THEN belong_nm
                ELSE belong_nm + N' 요회'
            END AS belong_nm
      FROM ubfgj3.dbo.[groups]
     WHERE ISNULL(etc1, 'N') = 'Y'
       AND retreat = @Retreat
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
              belong_nm ASC,
              seq ASC;
END
GO
