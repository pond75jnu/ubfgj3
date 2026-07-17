CREATE OR ALTER PROCEDURE dbo.SP_meal_access_guard_get
    @BROWSER_HASH CHAR(64),
    @IP_HASH CHAR(64),
    @NOW_UTC DATETIME2(0),
    @MAX_ATTEMPTS INT,
    @WINDOW_MINUTES INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MAX_ATTEMPTS < 1 OR @WINDOW_MINUTES < 1
        THROW 50311, N'접근 제한 설정이 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@BROWSER_HASH, '')) <> 64 OR @BROWSER_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50312, N'브라우저 식별 해시가 올바르지 않습니다.', 1;

    IF LEN(ISNULL(@IP_HASH, '')) <> 64 OR @IP_HASH LIKE '%[^0-9A-Fa-f]%'
        THROW 50313, N'IP 식별 해시가 올바르지 않습니다.', 1;

    ;WITH ScopeState AS
    (
        SELECT scope_type,
               CASE WHEN locked_until > @NOW_UTC THEN locked_until END AS active_locked_until,
               CASE WHEN locked_until > @NOW_UTC THEN failed_count
                    WHEN last_failed_at IS NULL THEN 0
                    WHEN DATEADD(MINUTE, @WINDOW_MINUTES, last_failed_at) <= @NOW_UTC THEN 0
                    ELSE failed_count
               END AS active_failed_count
          FROM dbo.meal_access_guard
         WHERE (scope_type = 'B' AND scope_hash = @BROWSER_HASH)
            OR (scope_type = 'I' AND scope_hash = @IP_HASH)
    )
    SELECT CASE WHEN MAX(active_locked_until) IS NULL THEN 'N' ELSE 'Y' END AS is_locked,
           MAX(active_locked_until) AS locked_until,
           ISNULL(MAX(active_failed_count), 0) AS failed_count,
           CASE WHEN @MAX_ATTEMPTS - ISNULL(MAX(active_failed_count), 0) < 0 THEN 0
                ELSE @MAX_ATTEMPTS - ISNULL(MAX(active_failed_count), 0)
           END AS remaining_attempts
      FROM ScopeState;
END
