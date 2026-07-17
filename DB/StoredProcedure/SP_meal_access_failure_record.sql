CREATE OR ALTER PROCEDURE dbo.SP_meal_access_failure_record
    @BROWSER_HASH CHAR(64),
    @IP_HASH CHAR(64),
    @NOW_UTC DATETIME2(0),
    @MAX_ATTEMPTS INT,
    @WINDOW_MINUTES INT,
    @LOCKOUT_MINUTES INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @MAX_ATTEMPTS < 1 OR @WINDOW_MINUTES < 1 OR @LOCKOUT_MINUTES < 1
        THROW 50321, N'접근 제한 설정이 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@BROWSER_HASH, '')) <> 64 OR @BROWSER_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50322, N'브라우저 식별 해시가 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@IP_HASH, '')) <> 64 OR @IP_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50323, N'IP 식별 해시가 올바르지 않습니다.', 1;

    DECLARE @Scopes TABLE
    (
        scope_type CHAR(1) NOT NULL PRIMARY KEY,
        scope_hash CHAR(64) NOT NULL
    );

    INSERT INTO @Scopes (scope_type, scope_hash)
    VALUES ('B', @BROWSER_HASH), ('I', @IP_HASH);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        UPDATE G WITH (UPDLOCK, HOLDLOCK)
           SET failed_count =
               CASE
                   WHEN G.locked_until > @NOW_UTC THEN G.failed_count
                   WHEN G.last_failed_at IS NULL
                     OR DATEADD(MINUTE, @WINDOW_MINUTES, G.last_failed_at) <= @NOW_UTC THEN 1
                   ELSE G.failed_count + 1
               END,
               window_started_at =
               CASE
                   WHEN G.locked_until > @NOW_UTC THEN G.window_started_at
                   WHEN G.last_failed_at IS NULL
                     OR DATEADD(MINUTE, @WINDOW_MINUTES, G.last_failed_at) <= @NOW_UTC THEN @NOW_UTC
                   ELSE G.window_started_at
               END,
               last_failed_at = CASE WHEN G.locked_until > @NOW_UTC THEN G.last_failed_at ELSE @NOW_UTC END,
               locked_until =
               CASE
                   WHEN G.locked_until > @NOW_UTC THEN G.locked_until
                   WHEN (CASE WHEN G.last_failed_at IS NULL
                                OR DATEADD(MINUTE, @WINDOW_MINUTES, G.last_failed_at) <= @NOW_UTC
                              THEN 1 ELSE G.failed_count + 1 END) >= @MAX_ATTEMPTS
                   THEN DATEADD(MINUTE, @LOCKOUT_MINUTES, @NOW_UTC)
                   ELSE NULL
               END,
               upt_dt = @NOW_UTC
          FROM dbo.meal_access_guard G
         INNER JOIN @Scopes S
            ON S.scope_type = G.scope_type
           AND S.scope_hash = G.scope_hash;

        INSERT INTO dbo.meal_access_guard
        (
            scope_type,
            scope_hash,
            failed_count,
            window_started_at,
            last_failed_at,
            locked_until,
            upt_dt
        )
        SELECT S.scope_type,
               S.scope_hash,
               1,
               @NOW_UTC,
               @NOW_UTC,
               CASE WHEN @MAX_ATTEMPTS <= 1
                    THEN DATEADD(MINUTE, @LOCKOUT_MINUTES, @NOW_UTC)
                    ELSE NULL END,
               @NOW_UTC
          FROM @Scopes S
         WHERE NOT EXISTS
               (
                   SELECT 1
                     FROM dbo.meal_access_guard G WITH (UPDLOCK, HOLDLOCK)
                    WHERE G.scope_type = S.scope_type
                      AND G.scope_hash = S.scope_hash
               );

        DECLARE @LockedUntil DATETIME2(0);
        DECLARE @FailedCount INT;

        SELECT @LockedUntil = MAX(CASE WHEN locked_until > @NOW_UTC THEN locked_until END),
               @FailedCount = MAX(failed_count)
          FROM dbo.meal_access_guard
         WHERE (scope_type = 'B' AND scope_hash = @BROWSER_HASH)
            OR (scope_type = 'I' AND scope_hash = @IP_HASH);

        COMMIT TRANSACTION;

        SELECT CASE WHEN @LockedUntil IS NULL THEN 'N' ELSE 'Y' END AS is_locked,
               @LockedUntil AS locked_until,
               ISNULL(@FailedCount, 0) AS failed_count,
               CASE WHEN @MAX_ATTEMPTS - ISNULL(@FailedCount, 0) < 0 THEN 0
                    ELSE @MAX_ATTEMPTS - ISNULL(@FailedCount, 0)
               END AS remaining_attempts;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
