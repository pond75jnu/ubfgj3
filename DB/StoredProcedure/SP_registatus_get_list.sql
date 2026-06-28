CREATE OR ALTER PROCEDURE dbo.SP_registatus_get_list
    @RETREAT INT,
    @BELONG NVARCHAR(20) = N'%',
    @REGI_TYPE NVARCHAR(10) = N'%'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER (ORDER BY
                              CASE WHEN A.user_dues <= 0 THEN 'N' ELSE 'Y' END ASC,
                              ISNULL(A.manager_confirm, 'N') DESC,
                              ISNULL(A.etc1, N'N') ASC,
                              C.belong_nm DESC,
                              A.user_nm DESC,
                              A.seq DESC) AS NUM,
           A.seq,
           A.user_nm,
           A.belong,
           C.belong_nm,
           A.usertype,
           CASE WHEN A.usertype = '1' THEN N'목자'
                WHEN A.usertype = '2' THEN N'목동'
                ELSE N'양' END AS usertype_nm,
           A.duestype,
           B.dues_nm,
           A.user_dues,
           FORMAT(A.user_dues, N'#,0') + N' 원' AS user_dues_won,
           ISNULL(A.howto_regist, 1) AS howto_regist,
           CASE WHEN ISNULL(A.howto_regist, 1) = 1 THEN N'계좌이체'
                ELSE N'현금납부' END AS howto_regist_nm,
           ISNULL(A.manager_confirm, 'N') AS manager_confirm,
           ISNULL(A.etc1, N'N') AS etc_confirm,
           A.user_desc,
           A.seq,
           CASE WHEN A.user_dues >= B.dues THEN 'table-success'
                WHEN A.user_dues <= 0 THEN 'table-danger'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 THEN 'table-warning'
           END AS regi_status_tr,
           CASE WHEN A.user_dues >= B.dues THEN N'완전등록'
                WHEN A.user_dues <= 0 THEN N'미등록'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 THEN N'부분등록'
           END AS regi_status_nm,
           CASE WHEN A.user_dues <= 0 THEN 'N' ELSE 'Y' END AS checkbox_visible,
           CASE WHEN ISNULL(A.etc1, N'N') = N'Y' AND ISNULL(A.manager_confirm, 'N') = 'N'
                THEN 'Y' ELSE '' END AS etc_notice
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
     INNER JOIN ubfgj3.dbo.groups C ON C.seq = A.belong
     WHERE A.retreat = @RETREAT
       AND ISNULL(C.etc1, N'') = N'Y'
       AND C.retreat = @RETREAT
       AND (@BELONG = N'%' OR A.belong = TRY_CONVERT(INT, @BELONG))
       AND
       (
           @REGI_TYPE NOT IN (N'1', N'2', N'3')
           OR (@REGI_TYPE = N'1' AND A.user_dues >= B.dues)
           OR (@REGI_TYPE = N'2' AND A.user_dues < B.dues AND A.user_dues > 0)
           OR (@REGI_TYPE = N'3' AND A.user_dues <= 0)
       )
     ORDER BY CASE WHEN A.user_dues <= 0 THEN 'N' ELSE 'Y' END DESC,
              ISNULL(A.manager_confirm, 'N') ASC,
              ISNULL(A.etc1, N'N') DESC,
              C.belong_nm ASC,
              A.user_nm ASC,
              A.seq ASC;
END

