/*
===============================================================================
Query Optimization: Indexing Strategy
===============================================================================
Rationale:
    To optimize the performance of the Gold layer views and the analytical 
    queries, we are creating Non-Clustered Indexes on the underlying Silver 
    table (silver.superstore_cleaned). 
    - Indexing foreign keys (Customer ID, Product ID, Location) speeds up JOINs.
    - Indexing Date columns speeds up time-series filtering and aggregations.
===============================================================================
*/

-- 1. Index for Customer lookups and joins
CREATE NONCLUSTERED INDEX IX_Silver_CustomerID 
ON silver.superstore_cleaned([Customer ID]);
GO

-- 2. Index for Product lookups and joins
CREATE NONCLUSTERED INDEX IX_Silver_ProductID 
ON silver.superstore_cleaned([Product ID]);
GO

-- 3. Index for Location-based aggregations
CREATE NONCLUSTERED INDEX IX_Silver_Location 
ON silver.superstore_cleaned([Country], [State], [City]);
GO

-- 4. Index for Date filtering (highly used in CTEs and Year-Over-Year queries)
CREATE NONCLUSTERED INDEX IX_Silver_OrderDate 
ON silver.superstore_cleaned([Order Date])
INCLUDE ([Sales], [Profit]); -- Included columns to prevent key lookups
GO