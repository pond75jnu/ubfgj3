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
