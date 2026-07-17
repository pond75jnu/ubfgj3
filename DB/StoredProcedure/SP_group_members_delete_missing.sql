CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_missing
    @RETREAT INT,
    @BELONG INT,
    @KEEP_SEQ_LIST NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KeepSeq TABLE
    (
        seq INT NOT NULL PRIMARY KEY
    );

    DECLARE @KeepSeqXml XML;
    SET @KEEP_SEQ_LIST = ISNULL(@KEEP_SEQ_LIST, N'');

    IF LEN(@KEEP_SEQ_LIST) > 0
    BEGIN
        SET @KeepSeqXml = TRY_CAST(N'<x>' + REPLACE(@KEEP_SEQ_LIST, N',', N'</x><x>') + N'</x>' AS XML);

        INSERT INTO @KeepSeq (seq)
        SELECT DISTINCT TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)'))
          FROM @KeepSeqXml.nodes(N'/x') AS T(N)
         WHERE TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)')) IS NOT NULL;
    END;

    DECLARE @DeleteSeq TABLE
    (
        seq INT NOT NULL PRIMARY KEY
    );

    INSERT INTO @DeleteSeq (seq)
    SELECT A.seq
      FROM ubfgj3.dbo.group_members A
     WHERE A.retreat = @RETREAT
       AND A.belong = @BELONG
       AND NOT EXISTS
           (
               SELECT 1
                 FROM @KeepSeq K
                WHERE K.seq = A.seq
           );

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE S
          FROM ubfgj3.dbo.meal_survey_selection S
         INNER JOIN @DeleteSeq D ON D.seq = S.group_member_seq;

        DELETE A
          FROM ubfgj3.dbo.group_members A
         INNER JOIN @DeleteSeq D ON D.seq = A.seq;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
