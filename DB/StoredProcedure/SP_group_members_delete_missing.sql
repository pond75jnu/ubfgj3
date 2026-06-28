CREATE OR ALTER PROCEDURE dbo.SP_group_members_delete_missing
    @RETREAT INT,
    @BELONG INT,
    @KEEP_SEQ_LIST NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

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
        SELECT DISTINCT TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)')) AS seq
          FROM @KeepSeqXml.nodes(N'/x') AS T(N)
         WHERE TRY_CONVERT(INT, T.N.value(N'.', N'nvarchar(20)')) IS NOT NULL;
    END

    DELETE A
      FROM ubfgj3.dbo.group_members A
     WHERE A.retreat = @RETREAT
       AND A.belong = @BELONG
       AND NOT EXISTS
           (
               SELECT 1
                 FROM @KeepSeq K
                WHERE K.seq = A.seq
           );
END

