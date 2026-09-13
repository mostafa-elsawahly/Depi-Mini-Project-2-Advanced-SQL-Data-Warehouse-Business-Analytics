/*
===============================================================================
DDL Script: Create Gold Views (Central Superstore)
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema).

    It extracts unique dimensions (Customers, Products, Locations) from the 
    Silver layer and links them via surrogate keys in the Fact table.
===============================================================================
*/

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