CREATE OR ALTER PROCEDURE dbo.SP_retreat_get_list
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER (ORDER BY seq, retreat_name) AS NUM,
           seq,
           retreat_name,
           retreat_place,
           retreat_sdt,
           retreat_edt,
           retreat_yn,
           SUBSTRING(retreat_sdt, 1, 4) + '-' + SUBSTRING(retreat_sdt, 5, 2) + '-' + SUBSTRING(retreat_sdt, 7, 2)
           + ' ~ ' +
           SUBSTRING(retreat_edt, 1, 4) + '-' + SUBSTRING(retreat_edt, 5, 2) + '-' + SUBSTRING(retreat_edt, 7, 2) AS retreat_term
      FROM ubfgj3.dbo.retreat_master
     ORDER BY seq DESC;
END

