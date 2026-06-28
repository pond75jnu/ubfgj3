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
