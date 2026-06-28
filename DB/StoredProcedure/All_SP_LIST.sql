SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
 * SP_group_all_list_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_group_all_list_sel]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm
      FROM ubfgj3.dbo.[groups]
     ORDER BY belong_nm, seq;
END
GO

GO

/******************************************************************************
 * SP_group_get_previous_by_name.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_get_previous_by_name
    @RETREAT INT,
    @BELONG_NM NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL(MAX(seq), -1) AS before_belong
      FROM ubfgj3.dbo.groups
     WHERE retreat = @RETREAT
       AND belong_nm = @BELONG_NM;
END

GO

/******************************************************************************
 * SP_group_member_save.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_member_save
    @SEQ INT = NULL,
    @USER_NM NVARCHAR(100),
    @BELONG INT,
    @RETREAT INT,
    @USERTYPE INT,
    @DUESTYPE INT,
    @USER_DUES INT,
    @HOWTO_REGIST INT,
    @USER_DESC NVARCHAR(300),
    @MANAGER_CONFIRM CHAR(1),
    @ATTEND NVARCHAR(300),
    @UID NVARCHAR(50),
    @UIP NVARCHAR(50),
    @AUTH NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF @SEQ IS NULL
    BEGIN
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
        SELECT @USER_NM,
               @BELONG,
               @RETREAT,
               @USERTYPE,
               @DUESTYPE,
               @USER_DUES,
               @HOWTO_REGIST,
               @USER_DESC,
               @MANAGER_CONFIRM,
               @MANAGER_CONFIRM,
               @ATTEND,
               @UID,
               @UIP,
               GETDATE(),
               @UID,
               @UIP,
               GETDATE();

        SELECT CONVERT(INT, @@IDENTITY) AS new_seq;
        RETURN;
    END

    UPDATE ubfgj3.dbo.group_members
       SET user_nm = @USER_NM,
           belong = @BELONG,
           retreat = @RETREAT,
           usertype = @USERTYPE,
           duestype = @DUESTYPE,
           user_dues = @USER_DUES,
           howto_regist = @HOWTO_REGIST,
           user_desc = @USER_DESC,
           manager_confirm = CASE WHEN @USER_DUES = 0 THEN 'N'
                                  WHEN ISNULL(manager_confirm, 'N') = 'Y'
                                       AND @AUTH = N'user'
                                       AND (user_dues <> @USER_DUES
                                            OR user_nm <> @USER_NM
                                            OR duestype <> @DUESTYPE)
                                      THEN 'N'
                                  WHEN @AUTH IN (N'admin', N'manager') THEN @MANAGER_CONFIRM
                                  ELSE ISNULL(manager_confirm, 'N') END,
           etc1 = CASE WHEN @USER_DUES = 0 THEN N'N'
                       WHEN ISNULL(manager_confirm, 'N') = 'N' THEN @MANAGER_CONFIRM
                       ELSE ISNULL(etc1, N'N') END,
           etc2 = @ATTEND,
           upt_id = @UID,
           upt_ip = @UIP,
           upt_dt = GETDATE()
     WHERE seq = @SEQ;

    SELECT @SEQ AS new_seq;
END

GO

/******************************************************************************
 * SP_group_members_delete_by_group.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_by_group
    @RETREAT INT,
    @BELONG INT,
    @DELETE_CONFIRMED CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @RETREAT
       AND belong = @BELONG
       AND
       (
           @DELETE_CONFIRMED = 'Y'
           OR
           (
               ISNULL(manager_confirm, 'N') = 'N'
               AND ISNULL(etc1, N'N') = N'N'
           )
       );
END

GO

/******************************************************************************
 * SP_group_members_delete_missing.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_missing
    @RETREAT INT,
    @BELONG INT,
    @KEEP_SEQ_LIST NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KeepSeq TABLE
    (
        seq INT NOT NULL PRIMARY KEY
    );

    DECLARE @KeepSeqXml XML;
    SET @KEEP_SEQ_LIST = ISNULL(@KEEP_SEQ_LIST, N'');

    IF LEN(@KEEP_SEQ_LIST) > 0
    BEGIN
        SET @KeepSeqXml = TRY_CAST(N'<x>' + REPLACE(@KEEP_SEQ_LIST, N',', N'</x><x>') + N'</x>' AS XML);

        INSERT INTO @KeepSeq (seq)
        SELECT DISTINCT TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)')) AS seq
          FROM @KeepSeqXml.nodes(N'/x') AS T(N)
         WHERE TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)')) IS NOT NULL;
    END

    DELETE A
      FROM ubfgj3.dbo.group_members A
     WHERE A.retreat = @RETREAT
       AND A.belong = @BELONG
       AND NOT EXISTS
           (
               SELECT 1
                 FROM @KeepSeq K
                WHERE K.seq = A.seq
           );
END

GO

/******************************************************************************
 * SP_group_members_get_by_retreat_belong.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_members_get_by_retreat_belong
    @RETREAT INT,
    @BELONG INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.*
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.groups B ON B.retreat = A.retreat
                                   AND B.seq = A.belong
     WHERE A.belong = @BELONG
       AND A.retreat = @RETREAT;
END

GO

/******************************************************************************
 * SP_group_members_get_for_usermanage.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_group_members_migrate.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_group_name_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_name_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE WHEN belong_nm LIKE N'%센터' THEN belong_nm ELSE belong_nm + N' 요회' END AS belong_nm
      FROM ubfgj3.dbo.groups
     WHERE seq = @Seq;
END

GO

/******************************************************************************
 * SP_group_retreat_list_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_group_retreat_list_sel]
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm
      FROM ubfgj3.dbo.[groups]
     WHERE retreat = @Retreat
     ORDER BY belong_nm, seq;
END
GO

GO

/******************************************************************************
 * SP_group_seq_by_name_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_seq_by_name_sel
    @BelongNm NVARCHAR(200),
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.groups
     WHERE belong_nm = @BelongNm
       AND retreat = @Retreat;
END

GO

/******************************************************************************
 * SP_group_seq_match_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_group_seq_match_sel
    @Seq INT,
    @BelongNm NVARCHAR(200),
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.groups
     WHERE seq = @Seq
       AND belong_nm = @BelongNm
       AND retreat = @Retreat;
END

GO

/******************************************************************************
 * SP_groups_get_active_by_retreat.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_groups_get_active_by_retreat
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           CASE WHEN belong_nm LIKE N'%센터' THEN belong_nm
                ELSE belong_nm + N' 요회' END AS belong_nm
      FROM ubfgj3.dbo.groups
     WHERE ISNULL(etc1, N'N') = N'Y'
       AND retreat = @RETREAT
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
              belong_nm ASC,
              seq ASC;
END

GO

/******************************************************************************
 * SP_income_summary_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_income_summary_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(seq) AS cnt,
           SUM(user_dues) AS total_regist,
           FORMAT(SUM(user_dues), N'#,0') + N' 원' AS total_regist_format
      FROM ubfgj3.dbo.group_members
     WHERE ISNULL(manager_confirm, '') = 'Y'
       AND user_dues > 0
       AND retreat = @Retreat;

    SELECT COUNT(A.payment) AS cnt,
           SUM(A.payment) AS total_payment,
           FORMAT(SUM(A.payment), N'#,0') + N' 원' AS total_payment_format
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.retreat = @Retreat
       AND B.cash_type = 1;
END

GO

/******************************************************************************
 * SP_manage_group_del.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_del]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.[groups]
     WHERE seq = @Seq;
END
GO

GO

/******************************************************************************
 * SP_manage_group_detail_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_detail_sel]
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq, belong_nm, manager, ISNULL(etc1, 'N') AS use_yn
      FROM ubfgj3.dbo.[groups]
     WHERE seq = @Seq;
END
GO

GO

/******************************************************************************
 * SP_manage_group_duplicate_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_duplicate_sel]
    @BelongNm NVARCHAR(200),
    @Seq INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT belong_nm
      FROM ubfgj3.dbo.[groups]
     WHERE belong_nm = @BelongNm
       AND (@Seq IS NULL OR seq <> @Seq);
END
GO

GO

/******************************************************************************
 * SP_manage_group_ins.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_ins]
    @BelongNm NVARCHAR(200),
    @Manager NVARCHAR(100),
    @Retreat INT,
    @UseYn CHAR(1),
    @LoginId NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.[groups]
        (belong_nm, manager, retreat, etc1, etc2, etc3, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt)
    VALUES
        (@BelongNm, @Manager, @Retreat, @UseYn, NULL, NULL, @LoginId, @UserIp, GETDATE(), @LoginId, @UserIp, GETDATE());
END
GO

GO

/******************************************************************************
 * SP_manage_group_list_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_list_sel]
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ubfgj3.dbo.[groups] WHERE retreat = @Retreat)
    BEGIN
        DECLARE @BeforeRetreat INT;

        SELECT @BeforeRetreat = MAX(retreat)
          FROM ubfgj3.dbo.[groups]
         WHERE retreat <> @Retreat;

        IF @BeforeRetreat IS NOT NULL
        BEGIN
            INSERT INTO ubfgj3.dbo.[groups]
                (belong_nm, manager, retreat, etc1, etc2, etc3, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt)
            SELECT belong_nm, manager, @Retreat, etc1, etc2, etc3, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt
              FROM ubfgj3.dbo.[groups]
             WHERE retreat = @BeforeRetreat;
        END
    END

    SELECT ROW_NUMBER() OVER (
               ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
                        belong_nm ASC,
                        seq ASC
           ) AS NUM,
           seq,
           belong_nm,
           manager,
           ISNULL(etc1, 'N') AS use_yn
      FROM ubfgj3.dbo.[groups]
     WHERE retreat = @Retreat
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
              belong_nm ASC,
              seq ASC;
END
GO

GO

/******************************************************************************
 * SP_manage_group_upd.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_group_upd]
    @Seq INT,
    @BelongNm NVARCHAR(200),
    @Manager NVARCHAR(100),
    @UseYn CHAR(1),
    @LoginId NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.[groups]
       SET belong_nm = @BelongNm,
           manager = @Manager,
           etc1 = @UseYn,
           upt_id = @LoginId,
           upt_ip = @UserIp,
           upt_dt = GETDATE()
     WHERE seq = @Seq;
END
GO

GO

/******************************************************************************
 * SP_manage_member_del.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_del]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId)
        OR LOWER(UserName) = LOWER(@LoginId);

    BEGIN TRANSACTION;

    DELETE FROM ubfgj3.dbo.aspnet_UsersInRoles
     WHERE UserId = @UserId;

    DELETE FROM ubfgj3.dbo.aspnet_Membership
     WHERE UserId = @UserId;

    DELETE FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId);

    DELETE FROM ubfgj3.dbo.member_master
     WHERE LOWER(login_id) = LOWER(@LoginId);

    COMMIT TRANSACTION;
END
GO

GO

/******************************************************************************
 * SP_manage_member_list_sel.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_manage_member_password_unlock_upd.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_password_unlock_upd]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE B
       SET IsLockedOut = 0,
           FailedPasswordAttemptCount = 0,
           Comment = '0'
      FROM ubfgj3.dbo.aspnet_Membership B
     INNER JOIN ubfgj3.dbo.aspnet_Users A ON A.UserId = B.UserId
     WHERE LOWER(A.UserName) = LOWER(@LoginId);
END
GO

GO

/******************************************************************************
 * SP_manage_member_upd.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_member_upd]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @Email NVARCHAR(256),
    @Status NVARCHAR(10),
    @RoleName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;
    DECLARE @RoleId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@LoginId);

    SELECT @RoleId = RoleId
      FROM ubfgj3.dbo.aspnet_Roles
     WHERE LoweredRoleName = LOWER(@RoleName)
        OR LOWER(RoleName) = LOWER(@RoleName);

    BEGIN TRANSACTION;

    UPDATE ubfgj3.dbo.aspnet_Membership
       SET Email = @Email,
           LoweredEmail = LOWER(@Email),
           IsApproved = CASE WHEN @Status = '1' THEN 1 ELSE 0 END
     WHERE UserId = @UserId;

    UPDATE ubfgj3.dbo.member_master
       SET kor_nm = @KorNm,
           belong = @Belong,
           email = @Email
     WHERE LOWER(login_id) = LOWER(@LoginId);

    IF @RoleId IS NOT NULL
    BEGIN
        UPDATE ubfgj3.dbo.aspnet_UsersInRoles
           SET RoleId = @RoleId
         WHERE UserId = @UserId;
    END

    COMMIT TRANSACTION;
END
GO

GO

/******************************************************************************
 * SP_manage_retreat_recent_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_manage_retreat_recent_sel]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (10) seq, retreat_name
      FROM ubfgj3.dbo.retreat_master
     ORDER BY seq DESC;
END
GO

GO

/******************************************************************************
 * SP_member_belong_upd.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_member_belong_upd
    @LoginId NVARCHAR(256),
    @Belong INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.member_master
       SET belong = @Belong
     WHERE LOWER(login_id) = LOWER(@LoginId);
END

GO

/******************************************************************************
 * SP_member_chk_id_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_chk_id_sel]
    @UserName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@UserName);
END
GO

GO

/******************************************************************************
 * SP_member_detail_sel.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_member_email_duplicate_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_email_duplicate_sel]
    @Email NVARCHAR(256),
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT email
      FROM ubfgj3.dbo.member_master
     WHERE LOWER(email) = LOWER(@Email)
       AND LOWER(login_id) <> LOWER(@LoginId);
END
GO

GO

/******************************************************************************
 * SP_member_find_id_sel.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_member_join_email_check_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_join_email_check_sel]
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LoweredEmail
      FROM ubfgj3.dbo.aspnet_Membership
     WHERE LoweredEmail = LOWER(@Email);
END
GO

GO

/******************************************************************************
 * SP_member_join_group_list_sel.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_member_master_by_login_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_member_master_by_login_sel
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT kor_nm,
           belong,
           belong_nm
      FROM ubfgj3.dbo.member_master
     WHERE LOWER(login_id) = LOWER(@LoginId);
END

GO

/******************************************************************************
 * SP_member_master_ins.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_master_ins]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @BelongNm NVARCHAR(200),
    @Email NVARCHAR(256),
    @UserIp NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.member_master
        (login_id, kor_nm, belong, belong_nm, email, ins_id, ins_ip, ins_dt, upt_id, upt_ip, upt_dt)
    VALUES
        (@LoginId, @KorNm, @Belong, @BelongNm, @Email, @LoginId, @UserIp, GETDATE(), @LoginId, @UserIp, GETDATE());
END
GO

GO

/******************************************************************************
 * SP_member_password_question_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_password_question_sel]
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT B.PasswordQuestion
      FROM ubfgj3.dbo.aspnet_Users A
     INNER JOIN ubfgj3.dbo.aspnet_Membership B ON B.UserId = A.UserId
     WHERE LOWER(A.UserName) = LOWER(@LoginId);
END
GO

GO

/******************************************************************************
 * SP_member_profile_upd.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_member_profile_upd]
    @LoginId NVARCHAR(256),
    @KorNm NVARCHAR(100),
    @Belong INT,
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LOWER(UserName) = LOWER(@LoginId);

    BEGIN TRANSACTION;

    UPDATE ubfgj3.dbo.aspnet_Membership
       SET Email = @Email,
           LoweredEmail = LOWER(@Email)
     WHERE UserId = @UserId;

    UPDATE ubfgj3.dbo.member_master
       SET kor_nm = @KorNm,
           belong = @Belong,
           email = @Email
     WHERE LOWER(login_id) = LOWER(@LoginId);

    COMMIT TRANSACTION;
END
GO

GO

/******************************************************************************
 * SP_menu_auth_by_path_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_auth_by_path_sel
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE WHEN LOWER(menu_auth) = 'user' THEN 'admin/manager/user'
                WHEN LOWER(menu_auth) = 'manager' THEN 'admin/manager'
                ELSE LOWER(menu_auth)
           END AS menu_auth
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@Path);
END

GO

/******************************************************************************
 * SP_menu_breadcrumb_current_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_breadcrumb_current_sel
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT parent_seq,
           menu_depth,
           menu_nm
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@Path);
END

GO

/******************************************************************************
 * SP_menu_by_seq_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_by_seq_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm,
           menu_path
      FROM ubfgj3.dbo.menu_master
     WHERE seq = @Seq;
END

GO

/******************************************************************************
 * SP_menu_left_by_path_auth_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_left_by_path_auth_sel
    @Path NVARCHAR(400),
    @Auth NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm,
           menu_path,
           menu_auth
      FROM ubfgj3.dbo.menu_master
     WHERE parent_seq = (
               SELECT parent_seq
                 FROM ubfgj3.dbo.menu_master
                WHERE LOWER(menu_path) = LOWER(@Path)
           )
       AND (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(menu_auth) = 'anonymous')
           )
     ORDER BY menu_order;
END

GO

/******************************************************************************
 * SP_menu_page_title_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_page_title_sel
    @MenuPath NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT menu_nm
      FROM ubfgj3.dbo.menu_master
     WHERE LOWER(menu_path) = LOWER(@MenuPath);
END

GO

/******************************************************************************
 * SP_menu_top_nav_child_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_top_nav_child_sel
    @Auth NVARCHAR(50),
    @ParentSeq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           parent_seq,
           menu_nm,
           menu_path,
           menu_depth,
           menu_order
      FROM ubfgj3.dbo.menu_master
     WHERE (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(menu_auth) = 'anonymous')
           )
       AND menu_depth = 1
       AND parent_seq = @ParentSeq
     ORDER BY menu_depth,
              menu_order;
END

GO

/******************************************************************************
 * SP_menu_top_nav_parent_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_menu_top_nav_parent_sel
    @Auth NVARCHAR(50),
    @Path NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.parent_seq,
           A.menu_nm,
           A.menu_path,
           A.menu_depth,
           A.menu_order,
           CASE WHEN EXISTS (SELECT 1 FROM ubfgj3.dbo.menu_master B WHERE B.parent_seq = A.seq) THEN 'Y' ELSE 'N' END AS subis,
           CASE WHEN EXISTS (SELECT 1 FROM ubfgj3.dbo.menu_master C WHERE C.parent_seq = A.seq AND LOWER(C.menu_path) = LOWER(@Path)) THEN 'Y' ELSE 'N' END AS pathis
      FROM ubfgj3.dbo.menu_master A
     WHERE (
               LOWER(@Auth) = 'admin'
            OR (LOWER(@Auth) = 'manager' AND LOWER(A.menu_auth) IN ('manager', 'user'))
            OR (LOWER(@Auth) = 'user' AND LOWER(A.menu_auth) = 'user')
            OR (LOWER(@Auth) = 'anonymous' AND LOWER(A.menu_auth) = 'anonymous')
           )
       AND A.menu_depth = 0
       AND ISNULL(A.menu_order, 0) <> 0
     ORDER BY A.menu_depth,
              A.parent_seq,
              A.menu_order;
END

GO

/******************************************************************************
 * SP_payment_expenses_summary_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_payment_expenses_summary_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(A.payment) AS cnt,
           SUM(A.payment) AS total_payment,
           FORMAT(SUM(A.payment), N'#,0') + N' 원' AS total_payment_format
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.retreat = @Retreat
       AND B.cash_type = 2;
END

GO

/******************************************************************************
 * SP_payment_master_by_seq_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_payment_master_by_seq_sel
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT cash_item_seq,
           file_path,
           file_url
      FROM ubfgj3.dbo.payment_master
     WHERE seq = @Seq;
END

GO

/******************************************************************************
 * SP_payment_print_detail_get.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_payment_print_detail_get
    @SEQ INT,
    @CASH_TYPE INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.retreat,
           A.cash_item_seq,
           B.item_nm,
           SUBSTRING(A.payment_dt, 1, 4) + '-' + SUBSTRING(A.payment_dt, 5, 2) + '-' + SUBSTRING(A.payment_dt, 7, 2) AS payment_dt,
           A.payment_item,
           A.payment,
           FORMAT(A.payment, N'#,0') + N' 원' AS payment_format,
           A.payment_item_desc,
           A.file_nm,
           A.file_type,
           A.file_url,
           A.file_path
      FROM ubfgj3.dbo.payment_master A
     INNER JOIN ubfgj3.dbo.cash_item_master B ON B.seq = A.cash_item_seq
     WHERE A.seq = @SEQ
       AND B.cash_type = @CASH_TYPE;
END

GO

/******************************************************************************
 * SP_regist_info_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_regist_info_sel
    @Retreat INT,
    @Belong NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.usertype,
           CASE WHEN A.usertype = 1 THEN N'목자'
                WHEN A.usertype = 2 THEN N'목동'
                ELSE N'양'
           END AS usertype_nm,
           CASE WHEN A.usertype = 3 THEN 'lamb'
                ELSE 'reader'
           END AS simple_usertype_nm,
           A.duestype,
           B.dues_nm,
           B.dues,
           A.user_dues,
           CASE WHEN A.user_dues >= B.dues AND A.usertype = 3 THEN 'lamb_complete'
                WHEN A.user_dues >= B.dues AND A.usertype <> 3 THEN 'reader_complete'
                WHEN A.user_dues <= 0 AND A.usertype = 3 THEN 'lamb_no_complete'
                WHEN A.user_dues <= 0 AND A.usertype <> 3 THEN 'reader_no_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype = 3 THEN 'lamb_p_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype <> 3 THEN 'reader_p_complete'
           END AS regi_type
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
     INNER JOIN ubfgj3.dbo.groups C ON C.seq = A.belong
     WHERE A.retreat = @Retreat
       AND (@Belong = N'%' OR A.belong = TRY_CONVERT(INT, @Belong));
END

GO

/******************************************************************************
 * SP_registatus_confirm_update.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_registatus_confirm_update
    @SEQ INT,
    @MANAGER_CONFIRM CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.group_members
       SET manager_confirm = @MANAGER_CONFIRM,
           etc1 = CASE WHEN ISNULL(etc1, N'N') = N'N' THEN @MANAGER_CONFIRM ELSE etc1 END
     WHERE seq = @SEQ;
END

GO

/******************************************************************************
 * SP_registatus_excel_get_list.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_registatus_get_list.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_retreat_active_file_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_file_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           file_nm,
           file_data
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

GO

/******************************************************************************
 * SP_retreat_active_get.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_get
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           seq,
           retreat_name
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

GO

/******************************************************************************
 * SP_retreat_active_info_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_info_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           seq,
           retreat_name,
           retreat_place,
           retreat_desc,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) AS retreat_sdt,
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_edt,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) + ' ~ ' +
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_term,
           file_nm
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

GO

/******************************************************************************
 * SP_retreat_active_other_check.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_other_check
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
       AND seq <> @SEQ;
END

GO

/******************************************************************************
 * SP_retreat_set_only_active.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_set_only_active
    @SEQ INT = NULL,
    @RETREAT_NAME NVARCHAR(100),
    @UID NVARCHAR(50),
    @UIP NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ACTIVE_SEQ INT;

    SELECT TOP (1)
           @ACTIVE_SEQ = seq
      FROM ubfgj3.dbo.retreat_master
     WHERE (@SEQ IS NOT NULL AND seq = @SEQ)
        OR (@SEQ IS NULL AND retreat_name = @RETREAT_NAME)
     ORDER BY seq DESC;

    IF @ACTIVE_SEQ IS NULL
    BEGIN
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE ubfgj3.dbo.retreat_master
       SET retreat_yn = 'Y',
           upt_id = @UID,
           upt_ip = @UIP,
           upt_dt = GETDATE()
     WHERE seq = @ACTIVE_SEQ
       AND ISNULL(retreat_yn, 'N') <> 'Y';

    UPDATE ubfgj3.dbo.retreat_master
       SET retreat_yn = 'N',
           upt_id = @UID,
           upt_ip = @UIP,
           upt_dt = GETDATE()
     WHERE seq <> @ACTIVE_SEQ
       AND ISNULL(retreat_yn, 'N') = 'Y';

    COMMIT TRANSACTION;
END

GO

/******************************************************************************
 * SP_retreat_current_code_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_current_code_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq,
           retreat_name
      FROM ubfgj3.dbo.retreat_master
     ORDER BY CASE WHEN ISNULL(retreat_yn, 'N') = 'Y' THEN 0 ELSE 1 END,
              seq DESC;
END

GO

/******************************************************************************
 * SP_retreat_delete_dependency_check.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_delete_dependency_check
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @SEQ
    UNION ALL
    SELECT seq
      FROM ubfgj3.dbo.retreatdues_master
     WHERE retreat = @SEQ;
END

GO

/******************************************************************************
 * SP_retreat_dues_by_retreat_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_dues_by_retreat_sel
    @Retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.seq,
           A.retreat,
           A.dues_nm,
           A.dues,
           FORMAT(A.dues, N'#,0') + N' 원' AS dues_format,
           A.dues_desc,
           B.etc1 AS bank_no
      FROM ubfgj3.dbo.retreatdues_master A
      LEFT OUTER JOIN ubfgj3.dbo.retreat_master B ON B.seq = A.retreat
     WHERE A.retreat = @Retreat
     ORDER BY A.dues_nm DESC,
              A.seq;
END

GO

/******************************************************************************
 * SP_retreat_file_get.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_file_get
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT file_nm,
           file_data
      FROM ubfgj3.dbo.retreat_master
     WHERE seq = @SEQ;
END

GO

/******************************************************************************
 * SP_retreat_get_detail.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_detail
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat_name,
           retreat_place,
           retreat_desc,
           file_nm,
           file_type,
           file_size,
           file_data,
           ISNULL(etc1, N'') AS retreat_bank_no,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) AS retreat_sdt,
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_edt
      FROM ubfgj3.dbo.retreat_master
     WHERE seq = @SEQ;
END

GO

/******************************************************************************
 * SP_retreat_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_list
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER (ORDER BY seq, retreat_name) AS NUM,
           seq,
           retreat_name,
           retreat_place,
           retreat_sdt,
           retreat_edt,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2)
           + ' ~ ' +
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_term
      FROM ubfgj3.dbo.retreat_master
     ORDER BY seq DESC;
END

GO

/******************************************************************************
 * SP_retreat_get_previous.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_previous
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL(MAX(seq), -1) AS before_retreat
      FROM ubfgj3.dbo.retreat_master
     WHERE seq < @RETREAT;
END

GO

/******************************************************************************
 * SP_retreat_name_duplicate_check.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreat_name_duplicate_check
    @RETREAT_NAME NVARCHAR(100),
    @SEQ INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT retreat_name
      FROM ubfgj3.dbo.retreat_master
     WHERE retreat_name = @RETREAT_NAME
       AND (@SEQ IS NULL OR seq <> @SEQ);
END

GO

/******************************************************************************
 * SP_retreatdues_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_retreatdues_get_list
    @RETREAT INT,
    @SORT_DIRECTION VARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           dues_nm,
           dues,
           FORMAT(dues, N'#,0') + N' 원' AS dues_format,
           dues_desc
      FROM ubfgj3.dbo.retreatdues_master
     WHERE retreat = @RETREAT
     ORDER BY CASE WHEN UPPER(ISNULL(@SORT_DIRECTION, 'ASC')) = 'DESC' THEN dues_nm END DESC,
              CASE WHEN UPPER(ISNULL(@SORT_DIRECTION, 'ASC')) <> 'DESC' THEN dues_nm END ASC,
              seq ASC;
END

GO

/******************************************************************************
 * SP_staff_cash_item_delete.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.cash_item_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_cash_item_get_detail.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_get_detail]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           cash_type,
           CASE WHEN cash_type = 1 THEN N'수입코드' ELSE N'지출코드' END AS cash_type_nm,
           item_nm,
           item_desc
    FROM ubfgj3.dbo.cash_item_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_cash_item_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_get_list]
    @cash_type INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER(ORDER BY cash_type, item_nm, seq) AS NUM,
           seq,
           retreat,
           cash_type,
           CASE WHEN cash_type = 1 THEN N'수입코드' ELSE N'지출코드' END AS cash_type_nm,
           item_nm,
           item_desc
    FROM ubfgj3.dbo.cash_item_master
    WHERE (@cash_type IS NULL OR cash_type = @cash_type)
    ORDER BY cash_type ASC,
             item_nm ASC,
             seq ASC;
END

GO

/******************************************************************************
 * SP_staff_cash_item_get_options.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_get_options]
    @cash_type INT,
    @exclude_retreat_dues BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           item_nm
    FROM ubfgj3.dbo.cash_item_master
    WHERE cash_type = @cash_type
      AND (@exclude_retreat_dues = 0 OR item_nm <> N'수양회비')
    ORDER BY item_nm ASC;
END

GO

/******************************************************************************
 * SP_staff_cash_item_has_payments.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_has_payments]
    @cash_item_seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq
    FROM ubfgj3.dbo.payment_master
    WHERE cash_item_seq = @cash_item_seq;
END

GO

/******************************************************************************
 * SP_staff_cash_item_insert.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_insert]
    @cash_type INT,
    @item_nm NVARCHAR(200),
    @item_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.cash_item_master (
        retreat,
        cash_type,
        item_nm,
        item_desc,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        1,
        @cash_type,
        @item_nm,
        @item_desc,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END

GO

/******************************************************************************
 * SP_staff_cash_item_update.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_cash_item_update]
    @seq INT,
    @cash_type INT,
    @item_nm NVARCHAR(200),
    @item_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.cash_item_master
    SET retreat = 1,
        cash_type = @cash_type,
        item_nm = @item_nm,
        item_desc = @item_desc,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_payment_delete.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.payment_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_payment_get_detail.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_get_detail]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           cash_item_seq,
           SUBSTRING(payment_dt, 1, 4) + '-' + SUBSTRING(payment_dt, 5, 2) + '-' + SUBSTRING(payment_dt, 7, 2) AS payment_dt,
           payment_item,
           payment,
           FORMAT(payment, N'#,0') AS payment_format_comma,
           payment_item_desc,
           file_nm,
           file_type,
           file_url,
           file_path
    FROM ubfgj3.dbo.payment_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_payment_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_get_list]
    @retreat INT,
    @cash_type INT,
    @excel_yn CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    EXEC ubfgj3.dbo.SP_income_get_list @retreat, @cash_type, @excel_yn;
END

GO

/******************************************************************************
 * SP_staff_payment_insert.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_insert]
    @retreat INT,
    @cash_item_seq INT,
    @payment_dt VARCHAR(8),
    @payment_item NVARCHAR(200),
    @payment DECIMAL(18, 0),
    @payment_item_desc NVARCHAR(MAX),
    @file_nm NVARCHAR(100),
    @file_type NVARCHAR(20),
    @file_url NVARCHAR(500),
    @file_path NVARCHAR(1000),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.payment_master (
        retreat,
        cash_item_seq,
        payment_dt,
        payment_item,
        payment,
        payment_item_desc,
        file_nm,
        file_type,
        file_url,
        file_path,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        @retreat,
        @cash_item_seq,
        @payment_dt,
        @payment_item,
        @payment,
        @payment_item_desc,
        @file_nm,
        @file_type,
        @file_url,
        @file_path,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END

GO

/******************************************************************************
 * SP_staff_payment_update.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_payment_update]
    @seq INT,
    @retreat INT,
    @cash_item_seq INT,
    @payment_dt VARCHAR(8),
    @payment_item NVARCHAR(200),
    @payment DECIMAL(18, 0),
    @payment_item_desc NVARCHAR(MAX),
    @del_file_yn CHAR(1),
    @file_nm NVARCHAR(100),
    @file_type NVARCHAR(20),
    @file_url NVARCHAR(500),
    @file_path NVARCHAR(1000),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.payment_master
    SET retreat = @retreat,
        cash_item_seq = @cash_item_seq,
        payment_dt = @payment_dt,
        payment_item = @payment_item,
        payment = @payment,
        payment_item_desc = @payment_item_desc,
        file_nm = CASE WHEN @del_file_yn = 'Y' THEN N''
                       WHEN @del_file_yn = 'A' THEN @file_nm
                       ELSE file_nm END,
        file_type = CASE WHEN @del_file_yn = 'Y' THEN N''
                         WHEN @del_file_yn = 'A' THEN @file_type
                         ELSE file_type END,
        file_url = CASE WHEN @del_file_yn = 'Y' THEN N''
                        WHEN @del_file_yn = 'A' THEN @file_url
                        ELSE file_url END,
        file_path = CASE WHEN @del_file_yn = 'Y' THEN N''
                         WHEN @del_file_yn = 'A' THEN @file_path
                         ELSE file_path END,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_retreat_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreat_get_list]
    @top_count INT,
    @active_only BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top_count) seq, retreat_name
    FROM ubfgj3.dbo.retreat_master
    WHERE (@active_only = 0 OR ISNULL(retreat_yn, 'N') = 'Y')
    ORDER BY seq DESC;
END

GO

/******************************************************************************
 * SP_staff_retreatdues_delete.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_delete]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ubfgj3.dbo.retreatdues_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_retreatdues_get_detail.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_get_detail]
    @seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat,
           dues_nm,
           dues,
           dues_desc
    FROM ubfgj3.dbo.retreatdues_master
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_staff_retreatdues_get_list.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_get_list]
    @retreat INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER(ORDER BY dues_nm DESC, seq DESC) AS NUM,
           seq,
           retreat,
           dues_nm,
           dues,
           FORMAT(dues, N'#,0') + N' 원' AS dues_format,
           dues_desc
    FROM ubfgj3.dbo.retreatdues_master
    WHERE retreat = @retreat
    ORDER BY dues_nm, seq;
END

GO

/******************************************************************************
 * SP_staff_retreatdues_has_members.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_has_members]
    @retreat INT,
    @dues_seq INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) seq
    FROM ubfgj3.dbo.group_members
    WHERE retreat = @retreat
      AND duestype = (
          SELECT seq
          FROM ubfgj3.dbo.retreatdues_master
          WHERE seq = @dues_seq
      );
END

GO

/******************************************************************************
 * SP_staff_retreatdues_insert.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_insert]
    @retreat INT,
    @dues_nm NVARCHAR(200),
    @dues DECIMAL(18, 0),
    @dues_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ubfgj3.dbo.retreatdues_master (
        retreat,
        dues_nm,
        dues,
        dues_desc,
        ins_id,
        ins_ip,
        ins_dt,
        upt_id,
        upt_ip,
        upt_dt
    )
    VALUES (
        @retreat,
        @dues_nm,
        @dues,
        @dues_desc,
        @user_id,
        @user_ip,
        GETDATE(),
        @user_id,
        @user_ip,
        GETDATE()
    );
END

GO

/******************************************************************************
 * SP_staff_retreatdues_update.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[SP_staff_retreatdues_update]
    @seq INT,
    @retreat INT,
    @dues_nm NVARCHAR(200),
    @dues DECIMAL(18, 0),
    @dues_desc NVARCHAR(MAX),
    @user_id NVARCHAR(50),
    @user_ip NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ubfgj3.dbo.retreatdues_master
    SET retreat = @retreat,
        dues_nm = @dues_nm,
        dues = @dues,
        dues_desc = @dues_desc,
        upt_id = @user_id,
        upt_ip = @user_ip,
        upt_dt = GETDATE()
    WHERE seq = @seq;
END

GO

/******************************************************************************
 * SP_status_attend_get_members.sql
 ******************************************************************************/
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

GO

/******************************************************************************
 * SP_status_group_targets.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_status_group_targets
    @RETREAT INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH TEMP AS
    (
        SELECT -1 AS seq, N'0' AS belong_nm
        UNION
        SELECT seq, belong_nm
          FROM ubfgj3.dbo.groups
         WHERE ISNULL(etc1, N'') = N'Y'
           AND retreat = @RETREAT
    )
    SELECT seq,
           belong_nm
      FROM TEMP
     ORDER BY CASE WHEN belong_nm LIKE N'%센터' THEN 2 ELSE 1 END ASC,
              belong_nm ASC;
END

GO

/******************************************************************************
 * SP_status_regist_get_members.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_status_regist_get_members
    @RETREAT INT,
    @BELONG INT = NULL
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
                WHEN A.user_dues <= 0 AND A.usertype = 3 THEN 'lamb_no_complete'
                WHEN A.user_dues <= 0 AND A.usertype <> 3 THEN 'reader_no_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype = 3 THEN 'lamb_p_complete'
                WHEN A.user_dues < B.dues AND A.user_dues > 0 AND A.usertype <> 3 THEN 'reader_p_complete'
           END AS regi_type
      FROM ubfgj3.dbo.group_members A
     INNER JOIN ubfgj3.dbo.retreatdues_master B ON B.seq = A.duestype
                                               AND B.retreat = A.retreat
     INNER JOIN ubfgj3.dbo.groups C ON C.seq = A.belong
     WHERE A.retreat = @RETREAT
       AND ISNULL(C.etc1, N'') = N'Y'
       AND (@BELONG IS NULL OR A.belong = @BELONG);
END

GO

/******************************************************************************
 * SP_userinfo_role_by_userid_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_userinfo_role_by_userid_sel
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT B.LoweredRoleName AS UserRole,
           B.Description AS RoleDesc
      FROM ubfgj3.dbo.aspnet_UsersInRoles A
     INNER JOIN ubfgj3.dbo.aspnet_Roles B ON B.RoleId = A.RoleId
     WHERE A.UserId = @UserId;
END

GO

/******************************************************************************
 * SP_userinfo_roleid_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_userinfo_roleid_sel
    @RoleName NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RoleId
      FROM ubfgj3.dbo.aspnet_Roles
     WHERE LoweredRoleName = LOWER(@RoleName);
END

GO

/******************************************************************************
 * SP_userinfo_userid_sel.sql
 ******************************************************************************/
CREATE OR ALTER PROCEDURE dbo.SP_userinfo_userid_sel
    @LoginId NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId
      FROM ubfgj3.dbo.aspnet_Users
     WHERE LoweredUserName = LOWER(@LoginId);
END

GO
