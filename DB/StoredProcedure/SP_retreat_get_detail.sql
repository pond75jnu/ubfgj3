CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_detail
    @SEQ INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT seq,
           retreat_name,
           retreat_place,
           retreat_desc,
           file_nm,
           file_type,
           file_size,
           file_data,
           ISNULL(etc1, N'') AS retreat_bank_no,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) AS retreat_sdt,
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_edt
      FROM ubfgj3.dbo.retreat_master
     WHERE seq = @SEQ;
END

