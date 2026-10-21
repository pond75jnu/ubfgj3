CREATE OR ALTER PROCEDURE dbo.SP_staff_history_get_list
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.seq, r.retreat_name,
           CASE WHEN TRY_CONVERT(DATE, r.retreat_sdt, 112) IS NOT NULL
                THEN LEFT(r.retreat_sdt, 4) ELSE N'연도 미등록' END AS retreat_year,
           ISNULL(CONVERT(NVARCHAR(10), TRY_CONVERT(DATE, r.retreat_sdt, 112), 23), N'기간 미등록') AS start_date,
           ISNULL(CONVERT(NVARCHAR(10), TRY_CONVERT(DATE, r.retreat_edt, 112), 23), N'') AS end_date,
           h.staff_names,
           COALESCE(h.bank_info, r.etc1, N'') AS bank_info
    FROM dbo.retreat_master r
    LEFT JOIN dbo.retreat_staff_history h ON h.retreat_seq = r.seq
    ORDER BY r.retreat_sdt DESC, r.seq DESC;
END;
