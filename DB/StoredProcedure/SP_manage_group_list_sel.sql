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
