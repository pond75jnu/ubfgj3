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

