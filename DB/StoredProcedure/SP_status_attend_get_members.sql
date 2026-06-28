CREATE OR ALTER PROCEDURE dbo.SP_status_attend_get_members
    @RETREAT INT,
    @BELONG INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT usertype,
           CASE WHEN usertype = 1 THEN N'목자'
                WHEN usertype = 2 THEN N'목동'
                ELSE N'양' END AS usertype_nm,
           CASE WHEN usertype = 3 THEN 'lamb'
                ELSE 'reader' END AS simple_usertype_nm,
           duestype,
           CASE WHEN usertype = 3 AND ISNULL(etc2, N'N') = N'A' THEN 'lamb_full_attend'
                WHEN usertype = 3 AND ISNULL(etc2, N'N') = N'P' THEN 'lamb_part_attend'
                WHEN usertype = 3 AND ISNULL(etc2, N'N') = N'N' THEN 'lamb_not_attend'
                WHEN usertype <> 3 AND ISNULL(etc2, N'N') = N'A' THEN 'reader_full_attend'
                WHEN usertype <> 3 AND ISNULL(etc2, N'N') = N'P' THEN 'reader_part_attend'
                WHEN usertype <> 3 AND ISNULL(etc2, N'N') = N'N' THEN 'reader_not_attend'
           END AS attend_type
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @RETREAT
       AND (@BELONG IS NULL OR belong = @BELONG);
END
