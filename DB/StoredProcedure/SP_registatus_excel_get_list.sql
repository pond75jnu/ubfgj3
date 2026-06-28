CREATE OR ALTER PROCEDURE dbo.SP_registatus_excel_get_list
    @RETREAT INT,
    @BELONG NVARCHAR(20) = N'%',
    @REGI_TYPE NVARCHAR(10) = N'%'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER (ORDER BY
                              CASE WHEN A.user_dues <= 0 THEN 'N' ELSE 'Y' END DESC,
                              ISNULL(A.manager_confirm, 'N') ASC,
                              ISNULL(A.etc1, N'N') DESC,
                              C.belong_nm ASC,
                              A.user_nm ASC,
                              A.seq ASC) AS [연번],
           C.belong_nm AS [요회],
           A.user_nm AS [이름],
           CASE WHEN A.usertype = '1' THEN N'목자'
                WHEN A.usertype = '2' THEN N'목동'
                ELSE N'양' END AS [회원구분],
           B.dues_nm AS [회비구분],
           A.user_dues AS [납부한금액],
           CASE WHEN ISNULL(A.howto_regist, 1) = 1 THEN N'계좌이체'
                ELSE N'현금납부' END AS [납부방법],
           CASE WHEN A.user_dues >= B.dues THEN N'완전등록'
                WHEN A.user_dues <= 0 THEN N'미등록'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 THEN N'부분등록'
           END AS [등록여부],
           CASE WHEN ISNULL(A.manager_confirm, 'N') = 'N' AND A.user_dues > 0 THEN N'미확인'
                WHEN A.user_dues <= 0 THEN N'미등록'
                ELSE N'확인함' END AS [실무자확인],
           CASE WHEN ISNULL(A.etc1, N'N') = N'Y' AND ISNULL(A.manager_confirm, 'N') = 'N'
                THEN N'재확인요청' ELSE N'' END AS [비고]
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
     INNER JOIN ubfgj3.dbo.groups C ON C.seq = A.belong
     WHERE A.retreat = @RETREAT
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

