-- VIEW: vw_ReconciliationIssues
-- Purpose: Identify completed transactions that have issues with settlements.
--          - 'missing_data' when a settlement does not exist
--          - 'data_mismatch' when transaction amount does not match settled amount
--          - 'valid' when everything matches
-- Usage: This view can be queried by compliance, risk, or reporting tools
--        to quickly monitor transaction reconciliation status.

USE FinanceReconciliation;
GO

IF OBJECT_ID('dbo.vw_ReconciliationIssues', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.vw_ReconciliationIssues;
END
GO

CREATE VIEW dbo.vw_ReconciliationIssues AS
SELECT
    t.TransactionID,
    t.Amount,
    s.SettledAmount,
    t.Status,
    CASE
        WHEN s.TransactionID IS NULL THEN 'missing_data'
        WHEN t.Amount <> s.SettledAmount THEN 'data_mismatch'
        ELSE 'valid'
    END AS IssueType
FROM dbo.Transactions t
LEFT JOIN dbo.Settlements s ON t.TransactionID = s.TransactionID
WHERE t.Status = 'completed';
GO

-- STORED PROCEDURE: sp_CheckReconciliationIssues
-- Purpose: Scan the vw_ReconciliationIssues view for any transactions
--          that have reconciliation issues (missing settlements or amount mismatches)
--          and log them into the AuditLog table with a timestamp and description.
-- Usage: Can be scheduled or executed manually to maintain an audit trail
--        for compliance and risk management purposes.
-- Steps:
--   1. Check vw_ReconciliationIssues for records where IssueType <> 'valid'
--   2. Insert a log entry into AuditLog for each issue found
--   3. Results can be reviewed by querying the AuditLog table

IF OBJECT_ID('dbo.sp_CheckReconciliationIssues', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckReconciliationIssues;
GO

CREATE PROCEDURE dbo.sp_CheckReconciliationIssues
AS
BEGIN
    SET NOCOUNT ON;

    -- Add log to AuditLog table
    INSERT INTO dbo.AuditLog (EventTime, Message)
    SELECT 
        GETDATE(), 
        'Issue found for TransactionID: ' + CAST(TransactionID AS NVARCHAR(20))
        + ', Type: ' + CAST(IssueType AS NVARCHAR(50))
    FROM dbo.vw_ReconciliationIssues
    WHERE IssueType <> 'valid';
END;
GO