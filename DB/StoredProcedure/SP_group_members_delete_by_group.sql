CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_by_group
    @RETREAT INT,
    @BELONG INT,
    @DELETE_CONFIRMED CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DeleteSeq TABLE
    (
        seq INT NOT NULL PRIMARY KEY
    );

    INSERT INTO @DeleteSeq (seq)
    SELECT seq
      FROM ubfgj3.dbo.group_members
     WHERE retreat = @RETREAT
       AND belong = @BELONG
       AND
       (
           @DELETE_CONFIRMED = 'Y'
           OR
           (
               ISNULL(manager_confirm, 'N') = 'N'
               AND ISNULL(etc1, N'N') = N'N'
           )
       );

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE S
          FROM ubfgj3.dbo.meal_survey_selection S
         INNER JOIN @DeleteSeq D ON D.seq = S.group_member_seq;

        DELETE M
          FROM ubfgj3.dbo.group_members M
         INNER JOIN @DeleteSeq D ON D.seq = M.seq;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
