SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID(N'dbo.retreat_staff_history', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.retreat_staff_history
    (
        retreat_seq INT NOT NULL PRIMARY KEY,
        staff_names NVARCHAR(300) NOT NULL,
        bank_info NVARCHAR(300) NULL,
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_retreat_staff_history_retreat FOREIGN KEY (retreat_seq)
            REFERENCES dbo.retreat_master(seq) ON DELETE CASCADE
    );
END;
DECLARE @parent INT, @count INT;
SELECT @parent = MIN(seq), @count = COUNT(*) FROM dbo.menu_master
WHERE menu_depth = 0 AND menu_nm = N'실무자';
IF @count <> 1 THROW 50001, N'실무자 상위 메뉴를 찾을 수 없습니다.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.menu_master WHERE menu_path IN ('/staff/history', '/staff/history.aspx'))
    INSERT dbo.menu_master(parent_seq, menu_nm, menu_path, menu_depth, menu_order, menu_auth)
    SELECT @parent, N'역대 실무자', '/staff/history.aspx', 1, ISNULL(MAX(menu_order), 0) + 1, 'manager'
    FROM dbo.menu_master WHERE parent_seq = @parent;
COMMIT;
