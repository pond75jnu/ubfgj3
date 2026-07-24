CREATE OR ALTER PROCEDURE dbo.SP_status_regist_get_members
    @RETREAT INT,
    @BELONG INT = NULL,
    @INCLUDE_UNREGISTERED BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.usertype,
           CASE WHEN A.usertype = 1 THEN N'목자'
                WHEN A.usertype = 2 THEN N'목동'
                ELSE N'양' END AS usertype_nm,
           CASE WHEN A.usertype = 3 THEN 'lamb'
                ELSE 'reader' END AS simple_usertype_nm,
           A.duestype,
           B.dues_nm,
           B.dues,
           A.user_dues,
           CASE WHEN A.user_dues >= B.dues AND A.usertype = 3 THEN 'lamb_complete'
                WHEN A.user_dues >= B.dues AND A.usertype <> 3 THEN 'reader_complete'
                WHEN ISNULL(A.user_dues, 0) <= 0 AND A.usertype = 3 THEN 'lamb_no_complete'
                WHEN ISNULL(A.user_dues, 0) <= 0 AND A.usertype <> 3 THEN 'reader_no_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype = 3 THEN 'lamb_p_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype <> 3 THEN 'reader_p_complete'
           END AS regi_type
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
                                               AND B.retreat = A.retreat
     INNER JOIN ubfgj3.dbo.groups C ON C.seq = A.belong
     WHERE A.retreat = @RETREAT
       AND ISNULL(C.etc1, N'') = N'Y'
       AND (@BELONG IS NULL OR A.belong = @BELONG)
       AND (@INCLUDE_UNREGISTERED = 1 OR ISNULL(A.user_dues, 0) > 0);
END
