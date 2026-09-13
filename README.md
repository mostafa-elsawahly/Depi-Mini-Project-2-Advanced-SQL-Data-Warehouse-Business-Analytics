# Mini-Project 2: Advanced SQL Data Warehouse & Business Analytics

## Project Overview

This project transforms raw operational data from the Central Superstore into a robust analytical relational database (Star Schema). The architecture consists of Bronze, Silver, and Gold layers to ensure data quality and provide a clean foundation for executive reporting.

## Data Architecture (Star Schema)

The Gold layer implements a fully normalized Star Schema with 5 logical entities:

* **Fact Table:** `gold.fact_sales` (Contains metrics like Sales, Quantity, Profit)
* **Dimension Tables:**
  1. `gold.dim_customers` (Customer details and segments)
  2. `gold.dim_products` (Categories and sub-categories)
  3. `gold.dim_location` (Geographical hierarchies)
  4. `gold.dim_date` (Time-series attributes)

## Query Optimization Strategy

To ensure optimal performance for the 15+ complex analytical queries, Non-Clustered Indexes were implemented on the underlying Silver table (`silver.superstore_cleaned`).

* **JOIN Optimization:** Indexes created on `Customer ID`, `Product ID`, and geographical columns.
* **Aggregation Speed:** An index on `Order Date` with included columns (`Sales`, `Profit`) was created to drastically reduce execution time for Year-Over-Year CTEs and window functions.

## Executive Business Insights

Based on the advanced SQL analytics performed (`analytics_reports.sql`), the following key insights were derived:

1. **Profitability Analysis:** The correlation between discounts and profit shows a sharp decline in profitability when discounts exceed 20%. Certain sub-categories consistently generate negative profit margins and require immediate pricing review.
2. **Customer Behavior:** VIP customers (spending >$5,000) account for a disproportionately large share of total revenue. However, a specific query identified customers who ordered in 2023 but churned in 2024, indicating a need for targeted retention campaigns.
3. **Sales Trends:** Year-Over-Year (YoY) growth analysis utilizing Window Functions (`LAG`) highlights seasonal spikes in Q4. Optimization of shipping times is recommended, as standard class shipping currently averages delays that could impact future customer retentio

# Advanced SQL Data Warehouse & Business Analytics

## Project Overview

This project transforms raw operational retail data (`Central_Superstore.csv`) into a structured analytical relational database. The primary objective is to build a robust data architecture that enables executive reporting, continuous KPI monitoring, and deep business analytics.

## Business Scenario

A retail organization needs to upgrade its data infrastructure to accurately measure profitability, track customer behavior, and forecast sales trends. This repository contains the complete SQL implementation required to migrate flat-file data into a high-performance relational model.

## Database Architecture

* **Data Modeling:** Designed a Star Schema architecture.
* **Normalization:** Deconstructed the raw dataset into distinct Fact and Dimension tables (exceeding the minimum 5 relational tables requirement).
* **Data Integrity:** Enforced strict Primary Key (PK) and Foreign Key (FK) relationships.

## Technical Implementation

This project utilizes advanced SQL techniques to process and analyze the data:

* **Advanced Querying:** Developed over 15 optimized SQL queries leveraging Subqueries and `CASE` statements.
* **Table Combinations:** Executed complex `JOIN` operations (3+ required) to aggregate data across multiple dimensions.
* **CTEs:** Implemented Common Table Expressions (2+ required) to simplify complex logic and improve query readability.
* **Database Objects:**
  * Created **SQL Views** to serve standardized data for reporting tools.
  * Developed **Stored Procedures** to automate and parameterize KPI calculations.
* **Performance:** Applied best practices in query writing to ensure fast execution and optimized performance.

## Analytical Focus

The business intelligence queries developed in this project focus on three core areas:

1. **Profitability Analysis:** Evaluating profit margins across different product categories and geographical regions.
2. **Customer Behavior:** Tracking purchase frequency, customer segments, and retention metrics.
3. **Sales Trends:** Time-series analysis to identify seasonal peaks and revenue growth.

## Project Structure

* `data/` - Contains the source dataset (`Central_Superstore.csv`).
* `sql_scripts/` - DDL and DML scripts (Schema creation, Views, Stored Procedures, and Analytical Queries).
* `docs/` - Additional documentation or grading rubrics.
