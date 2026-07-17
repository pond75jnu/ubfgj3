CREATE OR ALTER PROCEDURE dbo.SP_manage_group_del
    @Seq INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
          FROM ubfgj3.dbo.[groups]
         WHERE seq = @Seq
    )
        RETURN;

    IF EXISTS
    (
        SELECT 1
          FROM ubfgj3.dbo.[groups] A
         INNER JOIN ubfgj3.dbo.group_members B ON 1 = 1
         INNER JOIN ubfgj3.dbo.[groups] C ON C.seq = B.belong
         WHERE A.seq = @Seq
           AND C.belong_nm = A.belong_nm
    )
        RETURN;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE S
          FROM ubfgj3.dbo.meal_survey_selection S
         INNER JOIN ubfgj3.dbo.meal_survey_submission H ON H.seq = S.submission_seq
         WHERE H.belong = @Seq;

        DELETE FROM ubfgj3.dbo.meal_survey_submission
         WHERE belong = @Seq;

        DELETE FROM ubfgj3.dbo.[groups]
         WHERE seq = @Seq;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
