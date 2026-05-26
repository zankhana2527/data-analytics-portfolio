-- ============================================================
-- Change Over Time Analysis
-- Purpose : Track how key business metrics evolve over time
--           by aggregating sales data along date dimensions.
-- Metrics : Total Sales Revenue, Unique Customers, Units Sold
-- Source  : gold.fact_sales
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Monthly Sales Summary (Numeric Year/Month Columns)
-- Returns separate year and month integer columns, making it
-- easy to filter or sort by individual date parts in BI tools.
-- ------------------------------------------------------------
SELECT
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- ------------------------------------------------------------
-- Query 2: Monthly Sales Summary (Formatted Date Label)
-- Returns a single 'yyyy-MMM' string column (e.g. 2023-Jan)
-- for human-readable labels in reports and dashboards.
--
-- Note: DATETRUNC alternative is commented out below each
--       clause — swap in if a true date type is preferred
--       over a formatted string for downstream date parsing.
-- ------------------------------------------------------------
SELECT
	-- DATETRUNC(month, order_date) AS order_date,  
	FORMAT(order_date, 'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
-- GROUP BY  DATETRUNC(month, order_date)            
ORDER BY FORMAT(order_date, 'yyyy-MMM');
-- ORDER BY  DATETRUNC(month, order_date);          
