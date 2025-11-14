-- Initial LogViewer schema placeholder
-- For the exam: this represents the DB migration step.

CREATE TABLE IF NOT EXISTS LogEntries (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Level NVARCHAR(50),
    Message NVARCHAR(4000),
    CreatedAt DATETIME DEFAULT GETDATE()
);
