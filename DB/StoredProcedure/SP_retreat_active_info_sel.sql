CREATE OR ALTER PROCEDURE dbo.SP_retreat_active_info_sel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           seq,
           retreat_name,
           retreat_place,
           retreat_desc,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) AS retreat_sdt,
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_edt,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2) + ' ~ ' +
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_term,
           file_nm
      FROM ubfgj3.dbo.retreat_master
     WHERE ISNULL(retreat_yn, 'N') = 'Y'
     ORDER BY seq DESC;
END

