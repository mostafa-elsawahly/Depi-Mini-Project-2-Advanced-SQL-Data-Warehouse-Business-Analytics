-- Advanced SQL Data Warehouse (Superstore)
--This project utilizes the industry-standard **Medallion Architecture** to logically organize data as it flows through the system, ensuring high data quality and optimized performance for reporting.
-- 1. Bronze Layer (Raw Data)
--This is where data lands exactly as it appears in the source CSV file. We import everything as raw text (`NVARCHAR`) to prevent the bulk insert process from crashing if it encounters a malformed date or an unexpected character.
-- 2. Silver Layer (Cleaned Data)
--Here, we filter, clean, and format the data. We cast the raw text into proper SQL data types (like `INT`, `DATE`, `DECIMAL`), remove extra spaces using `TRIM`, and handle missing values. This step guarantees data integrity.
-- 3. Gold Layer (Business & Reporting)
--This is the final, polished stage. We take the clean data from the Silver layer and structure it into a **Star Schema** (Fact and Dimension tables). This layer is heavily optimized for business reporting, calculating KPIs, and feeding dashboards like Power BI.

USE master;
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DEPI_Mini_Project_2')
BEGIN
    ALTER DATABASE DEPI_Mini_Project_2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DEPI_Mini_Project_2;
END
GO
CREATE DATABASE DEPI_Mini_Project_2;
GO
USE DEPI_Mini_Project_2;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
-- ==============================================================================
-- 1. Bronze Layer (Raw Data Stage)
-- ==============================================================================
-- Purpose: Create a staging table to receive data from the CSV file exactly as-is.
--
-- Technical Notes:
-- 1. Using NVARCHAR(MAX) for all columns: 
--    All columns are defined as text to prevent the BULK INSERT process from 
--    failing if it encounters corrupted data, bad formats, or extra spaces. 
--    Proper data type casting (INT, DATE, DECIMAL) is deferred to the Silver layer.
--
-- 2. Square Brackets [ ]: 
--    Used to allow SQL Server to accept column names that contain spaces 
--    or special characters directly from the source file (e.g., [Row ID], [Sub-Category]).
-- ==============================================================================
GO
IF OBJECT_ID('bronze.superstore_raw', 'U') IS NOT NULL
DROP TABLE bronze.superstore_raw;
    CREATE TABLE bronze.superstore_raw (
[Row ID] NVARCHAR(MAX),
    [Order ID] NVARCHAR(MAX),
    [Order Date] NVARCHAR(MAX),
    [Ship Date] NVARCHAR(MAX),
    [Ship Mode] NVARCHAR(MAX),
    [Customer ID] NVARCHAR(MAX), 
    [Customer Name] NVARCHAR(MAX),
    [Segment] NVARCHAR(MAX),
    [Country] NVARCHAR(MAX),
    [City] NVARCHAR(MAX),
    [State] NVARCHAR(MAX),
    [Postal Code] NVARCHAR(MAX),
    [Region] NVARCHAR(MAX),
    [Product ID] NVARCHAR(MAX),
    [Category] NVARCHAR(MAX),
    [Sub-Category] NVARCHAR(MAX),
    [Product Name] NVARCHAR(MAX),
    [Sales] NVARCHAR(MAX),
    [Quantity] NVARCHAR(MAX),
    [Discount] NVARCHAR(MAX),
    [Profit] NVARCHAR(MAX)
);
GO
-- ==============================================================================
-- Stored Procedure: Load Bronze Layer (Source -> Bronze)
-- ==============================================================================
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer (Central Superstore)';
        PRINT '================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.superstore_raw';
        TRUNCATE TABLE bronze.superstore_raw;
        
        PRINT '>> Inserting Data Into: bronze.superstore_raw';
        BULK INSERT bronze.superstore_raw
        FROM 'C:\Users\Mostafa\Desktop\Central_Superstore.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ';',
            TABLOCK,
            CODEPAGE = '65001'
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
GO

-- ==============================================================================
-- TEST: Execute the procedure to load data
-- ==============================================================================
EXEC bronze.load_bronze;
GO

--===============================================================================
--===============================================================================
SELECT * 
FROM bronze.superstore_raw;

--===============================================================================
--===============================================================================
-- ==============================================================================
-- 2. DDL Script: Create Silver Table for Superstore (With Audit Column)
-- ==============================================================================
IF OBJECT_ID('silver.superstore_cleaned', 'U') IS NOT NULL
    DROP TABLE silver.superstore_cleaned;
GO

CREATE TABLE silver.superstore_cleaned (
    [Order ID] NVARCHAR(50),
    [Order Date] DATE,
    [Ship Date] DATE,
    [Ship Mode] NVARCHAR(50),
    [Customer ID] NVARCHAR(50),
    [Customer Name] NVARCHAR(100),
    [Segment] NVARCHAR(50),
    [Country] NVARCHAR(50),
    [City] NVARCHAR(50),
    [State] NVARCHAR(50),
    [Region] NVARCHAR(50),
    [Product ID] NVARCHAR(50),
    [Category] NVARCHAR(50),
    [Sub-Category] NVARCHAR(50),
    [Sales] DECIMAL(18, 4),
    [Quantity] INT,
    [Discount] DECIMAL(5, 2),
    [Profit] DECIMAL(18, 4),
    dwh_create_date DATETIME2 DEFAULT GETDATE() 
);
GO
-- ==============================================================================
-- 3. Stored Procedure: Load Silver Layer (Bronze -> Silver)
-- ==============================================================================
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer (Central Superstore)';
        PRINT '================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.superstore_cleaned';
        TRUNCATE TABLE silver.superstore_cleaned;
        
        PRINT '>> Inserting Data Into: silver.superstore_cleaned';
        INSERT INTO silver.superstore_cleaned (
            [Order ID], [Order Date], [Ship Date], [Ship Mode],
            [Customer ID], [Customer Name], [Segment], [Country], [City], [State],
            [Region], [Product ID], [Category], [Sub-Category],
            [Sales], [Quantity], [Discount], [Profit]
        )
        SELECT 
            TRIM([Order ID]),
            TRY_CONVERT(DATE, [Order Date], 103), 
            TRY_CONVERT(DATE, [Ship Date], 103),
            TRIM([Ship Mode]),
            TRIM([Customer ID]),
            TRIM([Customer Name]),
            TRIM([Segment]),
            TRIM([Country]),
            TRIM([City]),
            TRIM([State]),
            TRIM([Region]),
            TRIM([Product ID]),
            TRIM([Category]),
            TRIM([Sub-Category]),
            TRY_CAST(REPLACE([Sales], ',', '.') AS DECIMAL(18, 4)),
            TRY_CAST([Quantity] AS INT),
            TRY_CAST(REPLACE([Discount], ',', '.') AS DECIMAL(5, 2)),
            TRY_CAST(REPLACE([Profit], ',', '.') AS DECIMAL(18, 4))
        FROM bronze.superstore_raw;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
GO

EXEC silver.load_silver;
SELECT TOP 100 * FROM silver.superstore_cleaned;

--CHECK FORNULL OR DUPLICATE VALUES IN PRIMARY KEY 
--EXPECTATION: NO RESULTS
SELECT * 
FROM bronze.superstore_raw
WHERE [Order ID] IS NULL 
   OR [Product ID] IS NULL 
   OR [Customer ID] IS NULL;

SELECT 
    [Order ID], 
    [Product ID], 
    COUNT(*) AS Duplicate_Count
FROM bronze.superstore_raw
GROUP BY 
    [Order ID], 
    [Product ID]
HAVING COUNT(*) > 1;
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
--==================================================================================
--==================================================================================
--==================================================================================
-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY [Customer ID]) AS customer_key, -- Surrogate key
    [Customer ID] AS customer_id,
    [Customer Name] AS customer_name,
    [Segment] AS segment
FROM (
    SELECT DISTINCT
        [Customer ID],
        [Customer Name],
        [Segment]
    FROM silver.superstore_cleaned
    WHERE [Customer ID] IS NOT NULL
) AS t;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY [Product ID]) AS product_key, -- Surrogate key
    [Product ID] AS product_id,
    [Category] AS category,
    [Sub-Category] AS sub_category
FROM (
    SELECT DISTINCT
        [Product ID],
        [Category],
        [Sub-Category]
    FROM silver.superstore_cleaned
    WHERE [Product ID] IS NOT NULL
) AS t;
GO

-- =============================================================================
-- Create Dimension: gold.dim_location
-- =============================================================================
IF OBJECT_ID('gold.dim_location', 'V') IS NOT NULL
    DROP VIEW gold.dim_location;
GO

CREATE VIEW gold.dim_location AS
SELECT
    ROW_NUMBER() OVER (ORDER BY [Country], [State], [City]) AS location_key, -- Surrogate key
    [Country] AS country,
    [Region] AS region,
    [State] AS state,
    [City] AS city
FROM (
    SELECT DISTINCT
        [Country],
        [Region],
        [State],
        [City]
    FROM silver.superstore_cleaned
) AS t;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.[Order ID] AS order_id,
    cu.customer_key,
    pr.product_key,
    loc.location_key,
    sd.[Order Date] AS order_date,
    sd.[Ship Date] AS ship_date,
    sd.[Ship Mode] AS ship_mode,
    sd.[Sales] AS sales_amount,
    sd.[Quantity] AS quantity,
    sd.[Discount] AS discount,
    sd.[Profit] AS profit
FROM silver.superstore_cleaned sd
LEFT JOIN gold.dim_customers cu
    ON sd.[Customer ID] = cu.customer_id
LEFT JOIN gold.dim_products pr
    ON sd.[Product ID] = pr.product_id
LEFT JOIN gold.dim_location loc
    ON sd.[Country] = loc.country
   AND sd.[State] = loc.state
   AND sd.[City] = loc.city;
GO
SELECT TOP 10 * FROM gold.fact_sales;
-- ====================================================================
-- 1. Checking Dimensions for Duplicate or NULL Surrogate Keys
-- ====================================================================

-- Check 'gold.dim_customers'
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1 OR customer_key IS NULL;

-- Check 'gold.dim_products'
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1 OR product_key IS NULL;

-- Check 'gold.dim_location'
SELECT 
    location_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_location
GROUP BY location_key
HAVING COUNT(*) > 1 OR location_key IS NULL;


-- ====================================================================
-- 2. Checking Fact Table for Referential Integrity (Foreign Keys)
-- ====================================================================

-- Ensure all customer_keys in fact_sales exist in dim_customers
SELECT f.order_id, f.customer_key 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Ensure all product_keys in fact_sales exist in dim_products
SELECT f.order_id, f.product_key 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- Ensure all location_keys in fact_sales exist in dim_location
SELECT f.order_id, f.location_key 
FROM gold.fact_sales f
LEFT JOIN gold.dim_location l
    ON f.location_key = l.location_key
WHERE l.location_key IS NULL;