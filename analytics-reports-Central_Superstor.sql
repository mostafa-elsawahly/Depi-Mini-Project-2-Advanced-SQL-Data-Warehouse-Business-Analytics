-- ====================================================================
-- 1. STORED PROCEDURE FOR KPI CALCULATIONS
-- ====================================================================
IF OBJECT_ID('gold.sp_executive_kpis', 'P') IS NOT NULL
    DROP PROCEDURE gold.sp_executive_kpis;
GO

CREATE PROCEDURE gold.sp_executive_kpis
AS
BEGIN
    -- Calculates high-level Executive KPIs
    SELECT 
        COUNT(DISTINCT order_id) AS Total_Orders,
        COUNT(DISTINCT customer_key) AS Total_Customers,
        SUM(sales_amount) AS Total_Revenue,
        SUM(profit) AS Total_Profit,
        CAST((SUM(profit) / NULLIF(SUM(sales_amount), 0)) * 100 AS DECIMAL(5,2)) AS Profit_Margin_Percent
    FROM gold.fact_sales;
END;
GO

-- ====================================================================
-- 2. 15 ADVANCED ANALYTICAL QUERIES
-- ====================================================================

-- Query 1: Total Sales and Profit by Category (JOIN)
SELECT 
    p.category, 
    SUM(f.sales_amount) AS Total_Sales, 
    SUM(f.profit) AS Total_Profit
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY Total_Sales DESC;

-- Query 2: Top 10 Customers by Total Spend (JOIN & ORDER BY)
SELECT TOP 10
    c.customer_name, 
    SUM(f.sales_amount) AS Total_Spend,
    COUNT(f.order_id) AS Number_Of_Orders
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_name
ORDER BY Total_Spend DESC;

-- Query 3: Sales Trends by Year and Month (Date Functions)
SELECT 
    YEAR(order_date) AS Order_Year, 
    MONTH(order_date) AS Order_Month, 
    SUM(sales_amount) AS Monthly_Sales
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Order_Year, Order_Month;

-- Query 4: Customer Behavior - Segmentation using CASE statement
SELECT 
    c.customer_name,
    SUM(f.sales_amount) AS Total_Spend,
    CASE 
        WHEN SUM(f.sales_amount) > 5000 THEN 'VIP'
        WHEN SUM(f.sales_amount) BETWEEN 2000 AND 5000 THEN 'Premium'
        ELSE 'Standard'
    END AS Customer_Tier
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_name;

-- Query 5: Regional Profitability Analysis
SELECT 
    l.region, 
    SUM(f.profit) AS Regional_Profit,
    CASE 
        WHEN SUM(f.profit) < 0 THEN 'Loss Making'
        ELSE 'Profitable'
    END AS Profitability_Status
FROM gold.fact_sales f
JOIN gold.dim_location l ON f.location_key = l.location_key
GROUP BY l.region
ORDER BY Regional_Profit DESC;

-- Query 6: Products with Negative Profit (Subquery)
SELECT 
    product_id, 
    category, 
    sub_category 
FROM gold.dim_products
WHERE product_key IN (
    SELECT product_key 
    FROM gold.fact_sales 
    GROUP BY product_key 
    HAVING SUM(profit) < 0
);

-- Query 7: Sales Growth Year-Over-Year (CTE & Window Function)
WITH YearlySales AS (
    SELECT 
        YEAR(order_date) AS Sales_Year, 
        SUM(sales_amount) AS Total_Sales
    FROM gold.fact_sales
    GROUP BY YEAR(order_date)
)
SELECT 
    Sales_Year, 
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Sales_Year) AS Prev_Year_Sales,
    Total_Sales - LAG(Total_Sales) OVER (ORDER BY Sales_Year) AS YoY_Growth
FROM YearlySales;

-- Query 8: Average Shipping Time by Ship Mode (DATEDIFF)
SELECT 
    ship_mode, 
    AVG(DATEDIFF(DAY, order_date, ship_date)) AS Avg_Shipping_Days
FROM gold.fact_sales
GROUP BY ship_mode
ORDER BY Avg_Shipping_Days;

-- Query 9: Best Selling Sub-Category per Region (CTE & ROW_NUMBER)
WITH RankedSubCategories AS (
    SELECT 
        l.region, 
        p.sub_category, 
        SUM(f.sales_amount) AS Total_Sales,
        ROW_NUMBER() OVER(PARTITION BY l.region ORDER BY SUM(f.sales_amount) DESC) AS rank_num
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    JOIN gold.dim_location l ON f.location_key = l.location_key
    GROUP BY l.region, p.sub_category
)
SELECT region, sub_category, Total_Sales 
FROM RankedSubCategories 
WHERE rank_num = 1;

-- Query 10: Percentage of Orders with Discount (CASE & Aggregation)
SELECT 
    COUNT(order_id) AS Total_Orders,
    SUM(CASE WHEN discount > 0 THEN 1 ELSE 0 END) AS Discounted_Orders,
    CAST(SUM(CASE WHEN discount > 0 THEN 1.0 ELSE 0.0 END) / COUNT(order_id) * 100 AS DECIMAL(5,2)) AS Percent_Discounted
FROM gold.fact_sales;

-- Query 11: Top 5 Cities by Profit Margin (Complex Math)
SELECT TOP 5
    l.city,
    SUM(f.profit) AS Total_Profit,
    SUM(f.sales_amount) AS Total_Sales,
    (SUM(f.profit) / NULLIF(SUM(f.sales_amount), 0)) * 100 AS Profit_Margin
FROM gold.fact_sales f
JOIN gold.dim_location l ON f.location_key = l.location_key
GROUP BY l.city
ORDER BY Profit_Margin DESC;

-- Query 12: Customers who ordered in 2023 but not in 2024 (Subquery)
SELECT DISTINCT c.customer_name
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE YEAR(f.order_date) = 2023
  AND c.customer_key NOT IN (
      SELECT customer_key 
      FROM gold.fact_sales 
      WHERE YEAR(order_date) = 2024
  );

-- Query 13: Order Value Distribution (CTE & CASE)
WITH OrderTotals AS (
    SELECT order_id, SUM(sales_amount) AS Order_Value
    FROM gold.fact_sales
    GROUP BY order_id
)
SELECT 
    CASE 
        WHEN Order_Value < 50 THEN 'Low Value (<$50)'
        WHEN Order_Value BETWEEN 50 AND 500 THEN 'Medium Value ($50-$500)'
        ELSE 'High Value (>$500)'
    END AS Order_Size,
    COUNT(*) AS Order_Count
FROM OrderTotals
GROUP BY 
    CASE 
        WHEN Order_Value < 50 THEN 'Low Value (<$50)'
        WHEN Order_Value BETWEEN 50 AND 500 THEN 'Medium Value ($50-$500)'
        ELSE 'High Value (>$500)'
    END;

-- Query 14: Correlation between Discount and Profit (JOIN & Grouping)
SELECT 
    discount, 
    AVG(profit) AS Average_Profit,
    SUM(sales_amount) AS Total_Sales
FROM gold.fact_sales
WHERE discount IS NOT NULL
GROUP BY discount
ORDER BY discount ASC;

-- Query 15: Total Quantity Sold per State (JOIN)
SELECT 
    l.state, 
    SUM(f.quantity) AS Total_Items_Sold
FROM gold.fact_sales f
JOIN gold.dim_location l ON f.location_key = l.location_key
GROUP BY l.state
HAVING SUM(f.quantity) IS NOT NULL
ORDER BY Total_Items_Sold DESC;