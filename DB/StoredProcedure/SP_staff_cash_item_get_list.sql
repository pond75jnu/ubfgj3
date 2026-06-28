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
