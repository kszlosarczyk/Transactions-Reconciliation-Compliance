# Transactions Reconciliation (Compliance)

# Project Structure

FintechReconciliation/
-- README.md  
- Data/
-- Settlements.csv
-- Transactions.csv
- SQL/
-- 01_Create_DB_and_Tables.sql      -- DB + tables + data load
-- 02_Views_and_Procedures.sql      -- views + procedures
-- 03_Reconciliation_Check.sql      -- reconciliation queries                     

# Overview

This project demonstrates SQL-based data analysis and reconciliation for financial transactions in a fintech environment.
It simulates a real-world scenario where accurate transaction data and settlements are critical for compliance, risk management, and reporting.

The project includes:

- Generated data (~1000 transactions + ~800 settlements)
- Detection of missing settlements and amount mismatches
- Behavioral analysis per user with window functions
- Anomaly detection using statistical methods
- Aggregated statistics for reporting
- Compliance monitoring via a view
- Automated issue logging using a stored procedure

# Database Structure

## Transactions Table

| Column        | Type           | Description                                      |
|---------------|----------------|--------------------------------------------------|
| TransactionID | INT (PK)       | Unique transaction identifier                    |
| UserID        | INT            | ID of the user making the transaction            |
| Amount        | DECIMAL(10,2)  | Transaction amount                               |
| Status        | VARCHAR(20)    | Transaction status (completed, pending, failed)  |
| CreatedAt     | DATETIME       | Timestamp of transaction creation                |

## Settlements Table

| Column         | Type           | Description                     |
|----------------|----------------|---------------------------------|
| SettlementID   | INT (PK)       | Unique settlement identifier    |
| TransactionID  | INT            | Transaction reference           |
| SettledAmount  | DECIMAL(10,2)  | Amount settled                  |
| SettledAt      | DATETIME       | Timestamp of settlement         |

## AuditLog Table

| Column    | Type        | Description                    |
|-----------|-------------|--------------------------------|
| AuditID   | INT (PK)    | Auto-increment ID              |
| EventTime | DATETIME    | Time of the logged event       |
| Message   | NVARCHAR    | Description of the issue       |

# Features

1. Reconciliation Check
Identifies completed transactions that are missing settlements or have mismatched amounts.
Highlights potential financial and compliance issues.
2. Behavioral Analysis
Tracks cumulative transaction amounts per user.
Calculates average user spend using window functions.
3. Anomaly Detection
Identifies transactions >2 standard deviations above the mean.
Detects unusual activity or potential errors.
4. Aggregated Stats
Summarizes transaction count, total and average amount by status.
Useful for dashboard reporting.
5. Compliance View
vw_ReconciliationIssues provides an easy interface for monitoring reconciliation problems.
6. Stored Procedure
sp_CheckReconciliationIssues logs issues automatically into AuditLog.


# How to Run

1. Open 01_Create_DB_and_Tables.sql and execute in SQL Server Management Studio.
2. Open 02_Views_and_Procedures.sql and execute.
3. Open 03_Reconciliation_Check.sql and execute to perform analyses and generate reports.

# Notes
Data is simulated for demonstration purposes. The project can be extended to include dashboard reports, automated alerts or integration with BI tools.
