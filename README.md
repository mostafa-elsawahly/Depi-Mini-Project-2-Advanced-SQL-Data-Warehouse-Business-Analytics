# Advanced SQL Data Warehouse & Business Analytics

## Project Overview
This project transforms raw operational retail data (`Central_Superstore.xlsx`) into a structured analytical relational database. The primary objective is to build a robust data architecture that enables executive reporting, continuous KPI monitoring, and deep business analytics.

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
* `data/` - Contains the source dataset (`Central_Superstore.xlsx`).
* `sql_scripts/` - DDL and DML scripts (Schema creation, Views, Stored Procedures, and Analytical Queries).
* `docs/` - Additional documentation or grading rubrics.
