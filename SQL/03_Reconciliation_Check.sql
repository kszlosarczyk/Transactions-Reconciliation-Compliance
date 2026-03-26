-- Reconciliation Check
-- Purpose: Identify completed transactions that are either missing settlements or have mismatched amounts. 

USE FinanceReconciliation;
GO

WITH Reconciliation_Check AS (
    SELECT
        t.TransactionID,
        t.Amount,
        t.Status,
        s.SettledAmount,
        CASE
            WHEN s.TransactionID IS NULL THEN 'missing_settlement'
            WHEN t.Amount <> s.SettledAmount THEN 'amount_mismatch'
            ELSE 'valid'
        END AS IssueType
    FROM dbo.Transactions t
    LEFT JOIN dbo.Settlements s ON t.TransactionID = s.TransactionID
    WHERE t.Status = 'completed'
)

SELECT *
FROM Reconciliation_Check
WHERE IssueType <> 'valid';
GO

-- Behavioural Analysis
-- Purpose: Track cumulative transaction amounts and average spend per user.

SELECT
    UserID,
    TransactionID,
    Amount,
    SUM(Amount) OVER (PARTITION BY UserID ORDER BY CreatedAt ROWS UNBOUNDED PRECEDING) AS RunningTotal,
    AVG(Amount) OVER (PARTITION BY UserID) AS AvgUserSpend
FROM dbo.Transactions;
GO

-- Anomaly Detection
-- Purpose: Identify transactions that are significantly higher than average (2 standard deviations above mean)

WITH Stats AS (
    SELECT
		UserID,
        TransactionID,
        Amount,
        AVG(Amount) OVER () AS AvgAmount,
        STDEV(Amount) OVER () AS StdDevAmount
    FROM dbo.Transactions
)

SELECT *
FROM Stats
WHERE Amount > AvgAmount + 2 * StdDevAmount;
GO

-- Aggregated Stats
-- Purpose: Summarize transaction count, total and average amount by status.

SELECT
    Status,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AvgAmount
FROM dbo.Transactions
GROUP BY Status;
GO

-- Saving data to AuditLog table
EXEC dbo.sp_CheckReconciliationIssues;
GO

-- Audit Log tableCheck
SELECT * 
FROM dbo.AuditLog;
GO