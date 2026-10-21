CREATE OR ALTER PROCEDURE dbo.SP_staff_history_save
    @RetreatSeq INT,
    @StaffNames NVARCHAR(300),
    @BankInfo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM dbo.retreat_master WITH (UPDLOCK, HOLDLOCK) WHERE seq = @RetreatSeq)
        THROW 50001, N'수양회가 존재하지 않습니다.', 1;
    UPDATE dbo.retreat_staff_history SET staff_names = @StaffNames,
        bank_info = @BankInfo, updated_at = SYSDATETIME() WHERE retreat_seq = @RetreatSeq;
    IF @@ROWCOUNT = 0
        INSERT dbo.retreat_staff_history(retreat_seq, staff_names, bank_info)
        VALUES (@RetreatSeq, @StaffNames, @BankInfo);
    COMMIT;
END;
