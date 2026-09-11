/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
-- ==============================================================================
-- 1. Bronze Layer (Raw Data)
-- ==============================================================================
GO
IF OBJECT_ID('bronze.superstore_raw', 'U') IS NOT NULL
    DROP TABLE bronze.superstore_raw;
GO

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
-- Stored Procedure for Bulk Insert into Bronze Layer
-- ==============================================================================
-- 1. FIRSTROW = 2: Skips the header row.
-- 2. FIELDTERMINATOR = ';': Sets the semicolon as the column delimiter.
-- 3. TABLOCK: Locks the entire table to speed up the insert and reduce resource usage.
-- 4. CODEPAGE = '65001': Uses UTF-8 encoding to ensure text and symbols are read correctly.
-- ==============================================================================
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    BEGIN TRY
        PRINT '==============================================';
        PRINT 'Loading data into Bronze Layer (Raw Data Stage)';
        PRINT '==============================================';
        PRINT '----------------------------------------------';
        PRINT ' Loading data from CSV file into superstore table';
        PRINT '----------------------------------------------';
        
        PRINT '>> TRUNCATING TABLE bronze.superstore_raw';
        TRUNCATE TABLE bronze.superstore_raw;
        
        PRINT '>> INSERTING data into bronze.superstore_raw';
        BULK INSERT bronze.superstore_raw
        FROM 'C:\Users\Mostafa\Desktop\Central_Superstore.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ';',
            TABLOCK,
            CODEPAGE = '65001'
        );
    END TRY
    BEGIN CATCH
        PRINT '==============================================';
        PRINT 'Error occurred while loading data into Bronze Layer';
        PRINT ERROR_MESSAGE();
        PRINT '==============================================';
    END CATCH
END;
GO

-- ==============================================================================
-- TEST: Verify that the data has been loaded correctly into the Bronze layer.
-- ==============================================================================
EXEC bronze.load_bronze;
GO

SELECT COUNT(*) AS Total_Rows FROM bronze.superstore_raw;
SELECT TOP 10 * FROM bronze.superstore_raw;
GO
