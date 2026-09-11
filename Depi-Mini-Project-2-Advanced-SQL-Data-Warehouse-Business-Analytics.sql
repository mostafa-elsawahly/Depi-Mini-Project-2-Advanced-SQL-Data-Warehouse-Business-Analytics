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
