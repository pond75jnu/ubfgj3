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
