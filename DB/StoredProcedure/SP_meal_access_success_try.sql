CREATE OR ALTER PROCEDURE dbo.SP_meal_access_success_try
    @BROWSER_HASH CHAR(64),
    @IP_HASH CHAR(64),
    @NOW_UTC DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF LEN(ISNULL(@BROWSER_HASH, '')) <> 64 OR @BROWSER_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50331, N'브라우저 식별 해시가 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@IP_HASH, '')) <> 64 OR @IP_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50332, N'IP 식별 해시가 올바르지 않습니다.', 1;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        DECLARE @LockedUntil DATETIME2(0);

        SELECT @LockedUntil = MAX(locked_until)
          FROM dbo.meal_access_guard WITH (UPDLOCK, HOLDLOCK)
         WHERE locked_until > @NOW_UTC
           AND ((scope_type = 'B' AND scope_hash = @BROWSER_HASH)
             OR (scope_type = 'I' AND scope_hash = @IP_HASH));

        IF @LockedUntil IS NOT NULL
        BEGIN
            COMMIT TRANSACTION;
            SELECT N'LOCKED' AS result_code,
                   @LockedUntil AS locked_until;
            RETURN;
        END;

        UPDATE dbo.meal_access_guard
           SET failed_count = 0,
               window_started_at = @NOW_UTC,
               last_failed_at = NULL,
               locked_until = NULL,
               upt_dt = @NOW_UTC
         WHERE (scope_type = 'B' AND scope_hash = @BROWSER_HASH)
            OR (scope_type = 'I' AND scope_hash = @IP_HASH);

        COMMIT TRANSACTION;

        SELECT N'AUTHORIZED' AS result_code,
               CAST(NULL AS DATETIME2(0)) AS locked_until;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
