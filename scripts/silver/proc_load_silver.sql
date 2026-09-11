/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate 
    'silver.superstore_cleaned' from 'bronze.superstore_raw'.
===============================================================================
*/

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
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
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