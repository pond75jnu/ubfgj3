CREATE OR ALTER PROCEDURE dbo.SP_group_members_migrate
    @RETREAT INT,
    @BELONG INT,
    @BEFORE_RETREAT INT,
    @BEFORE_BELONG INT,
    @UID NVARCHAR(50),
    @UIP NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.group_members
    (
        user_nm,
        belong,
        retreat,
        usertype,
        duestype,
        user_dues,
        howto_regist,
        user_desc,
        manager_confirm,
        etc1,
        etc2,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    SELECT A.user_nm,
           @BELONG AS belong,
           @RETREAT AS retreat,
           A.usertype,
           ISNULL(C.seq, (SELECT MAX(seq) FROM ubfgj3.dbo.retreatdues_master WHERE retreat = 10)) AS duestype,
           0 AS user_dues,
           1 AS howto_regist,
           N'' AS user_desc,
           'N' AS manager_confirm,
           'N' AS etc1,
           'N' AS etc2,
           @UID AS ins_id,
           @UIP AS ins_ip,
           GETDATE() AS ins_dt,
           @UID AS upt_id,
           @UIP AS upt_ip,
           GETDATE() AS upt_dt
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
                                               AND B.retreat = A.retreat
      LEFT OUTER JOIN ubfgj3.dbo.retreatdues_master C ON C.dues_nm = B.dues_nm
                                                     AND C.retreat = @RETREAT
     WHERE A.belong = @BEFORE_BELONG
       AND A.retreat = @BEFORE_RETREAT;
END

