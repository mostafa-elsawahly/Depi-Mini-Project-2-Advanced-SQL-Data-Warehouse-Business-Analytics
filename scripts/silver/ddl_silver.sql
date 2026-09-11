/*
===============================================================================
DDL Script: Create Silver Table for Superstore
===============================================================================
Script Purpose:
    This script creates the cleaned table in the 'silver' schema, dropping it 
    if it already exists.
===============================================================================
*/

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