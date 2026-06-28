CREATE OR ALTER PROCEDURE dbo.SP_group_members_get_for_usermanage
    @RETREAT INT,
    @BELONG INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.user_nm,
           A.belong,
           A.usertype,
           A.duestype,
           A.user_dues,
           FORMAT(A.user_dues, N'#,0') AS user_dues_format_comma,
           ISNULL(A.howto_regist, 1) AS howto_regist,
           ISNULL(A.manager_confirm, 'N') AS manager_confirm,
           A.user_desc,
           A.seq,
           CASE WHEN A.user_dues >= B.dues THEN 'table-success'
                WHEN A.user_dues <= 0 THEN 'table-danger'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 THEN 'table-warning'
           END AS regi_status,
           ISNULL(A.etc1, N'N') AS manager_confirm_first,
           ISNULL(A.etc2, N'N') AS attend
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
                                               AND B.retreat = A.retreat
     WHERE A.retreat = @RETREAT
       AND A.belong = @BELONG;
END

