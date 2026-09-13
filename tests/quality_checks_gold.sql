/*
===============================================================================
Quality Control Scripts: Check GOLD Layer (Superstore)
===============================================================================
Script Purpose:
    This script performs data quality checks on the Gold layer views.
    It ensures:
    1. Uniqueness of surrogate keys in dimension views.
    2. Referential integrity between the fact table and dimension views.
===============================================================================
*/

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