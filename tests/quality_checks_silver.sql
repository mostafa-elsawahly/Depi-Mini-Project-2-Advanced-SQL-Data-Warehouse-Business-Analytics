/*
===============================================================================
Quality Control Scripts: Check SILVER Layer (Superstore)
===============================================================================
Script Purpose:
    This script performs data quality checks on the Silver layer table 
    (silver.superstore_cleaned). It flags bad data, nulls, and business anomalies.
===============================================================================
*/

-- ====================================================================
-- 1. Check for NULLs or Blanks in Core IDs
-- ====================================================================
SELECT 
    COUNT(CASE WHEN [Order ID] IS NULL OR [Order ID] = '' THEN 1 END) AS null_order_ids,
    COUNT(CASE WHEN [Customer ID] IS NULL OR [Customer ID] = '' THEN 1 END) AS null_customer_ids,
    COUNT(CASE WHEN [Product ID] IS NULL OR [Product ID] = '' THEN 1 END) AS null_product_ids
FROM silver.superstore_cleaned;

-- ====================================================================
-- 2. Check for Date Logic (Ship Date before Order Date is invalid)
-- ====================================================================
SELECT 
    [Order ID], 
    [Order Date], 
    [Ship Date]
FROM silver.superstore_cleaned
WHERE [Ship Date] < [Order Date];

-- ====================================================================
-- 3. Check for Invalid Numeric Values (Sales/Quantity shouldn't be <= 0)
-- ====================================================================
SELECT 
    [Order ID], 
    [Product ID], 
    [Sales], 
    [Quantity]
FROM silver.superstore_cleaned
WHERE [Sales] <= 0 OR [Quantity] <= 0;

-- ====================================================================
-- 4. Check for Potential Duplicates at the Line Item Level
-- (An order typically shouldn't have the exact same product twice unless split)
-- ====================================================================
SELECT 
    [Order ID], 
    [Product ID], 
    COUNT(*) AS duplicate_count
FROM silver.superstore_cleaned
GROUP BY [Order ID], [Product ID]
HAVING COUNT(*) > 1;

-- ====================================================================
-- 5. Check for Unwanted Spaces in Text Columns (Ensuring TRIM worked)
-- ====================================================================
SELECT 
    [Customer ID], 
    [Customer Name],
    [Product ID],
    [Category]
FROM silver.superstore_cleaned
WHERE [Customer Name] LIKE ' %' OR [Customer Name] LIKE '% '
   OR [Customer ID] LIKE ' %' OR [Customer ID] LIKE '% '
   OR [Product ID] LIKE ' %' OR [Product ID] LIKE '% '
   OR [Category] LIKE ' %' OR [Category] LIKE '% ';