-- ============================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- Target Layer : gold (star schema — fact + dimensions)
-- Purpose      : Validate data completeness, profile key metrics,
--                and surface distribution patterns before formal
--                reporting or model development.
-- ============================================================

-- ============================================================
-- SECTION 1 | SCHEMA & OBJECT DISCOVERY
-- Enumerate all tables and columns available in the database.
-- Run these first to confirm the gold layer objects are present
-- and the schema matches expectations post-load.
-- ============================================================

-- Catalog every user table and view in the current database.
-- Useful for a quick sanity-check after a pipeline run.
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Inspect the full column manifest for a specific table,
-- including data types, nullability, and ordinal position.
-- Swap TABLE_NAME to audit any other object in the warehouse.
SELECT *
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'dim_customers';


-- ============================================================
-- SECTION 2 | DIMENSION PROFILING
-- Enumerate distinct member values within key dimensions.
-- Drives cardinality awareness and informs filter design
-- for downstream reports and dashboard slicers.
-- ============================================================

-- Customer geography: distinct countries present in the dataset.
SELECT DISTINCT country
FROM   gold.dim_customers;

-- Product hierarchy: distinct category > subcategory > product
-- combinations. Composite ORDER BY mirrors the natural rollup
-- so the output can be eye-scanned top-down.
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM  gold.dim_products
ORDER BY 1, 2, 3;

-- ============================================================
-- SECTION 3 | DATE RANGE & TEMPORAL BOUNDARY ANALYSIS
-- Establish the earliest and latest timestamps in each
-- time-sensitive table. This defines the analysis window
-- and flags any unexpected gaps or future-dated records.
-- ============================================================

-- Sales horizon: order date floor and ceiling plus integer
-- spans in both years and months for quick comprehension.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(year,  MIN(order_date), MAX(order_date)) AS order_range_years,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Customer age range: derive oldest and youngest ages at
-- query time using GETDATE(), which keeps the figures current
-- without requiring a scheduled refresh.
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(year, MIN(birthdate), GETDATE() AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

-- ============================================================
-- SECTION 4 | KEY BUSINESS METRICS (TOP-LEVEL AGGREGATES)
-- Compute the highest-level KPIs across the entire dataset.
-- These serve as the "north star" figures — any slice-level
-- number later in the analysis should roll up to these totals.
-- ============================================================

-- Total gross revenue across all orders and periods.
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Total units sold — distinct from order count when
-- multi-line orders are common.
SELECT
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Mean transaction price; useful for detecting
-- price-mix shifts over time.
SELECT
    AVG(price) AS average_selling_price
FROM gold.fact_sales;

-- Order volume: raw row count vs. distinct order numbers.
-- A gap between the two confirms multi-line order structure.
SELECT
    COUNT(order_number) AS total_orders,
    COUNT(DISTINCT order_number) AS unique_total_orders
FROM gold.fact_sales;

-- Product catalogue size: raw vs. distinct product keys.
-- Divergence may indicate duplicate or surrogate key issues.
SELECT
    COUNT(product_key) AS total_products,
    COUNT(DISTINCT product_key) AS unique_total_products
FROM gold.dim_products;

-- Total customer count registered in the dimension table.
SELECT
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- Active buyer count: customers who appear in at least one
-- sales transaction. JOIN to fact isolates engaged customers
-- from those who registered but never converted.
SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers_with_orders
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales     s
       ON c.customer_id = s.customer_key;

-- ============================================================
-- Consolidated KPI summary: all headline metrics in a single
-- result set via UNION ALL. Ideal for a single-query
-- dashboard snapshot or documentation appendix.
-- ============================================================
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;

-- ============================================================
-- SECTION 5 | MAGNITUDE ANALYSIS — MEASURES BY DIMENSION
-- Break top-level aggregates down by categorical attributes.
-- Highlights which segments carry disproportionate weight
-- and where to focus optimisation or marketing effort.
-- ============================================================

-- Customer split by gender: useful for product targeting
-- and demographic representation checks.
SELECT
    gender,
    COUNT(customer_id) AS total_customers
FROM  gold.dim_customers
GROUP BY gender;

-- Customer concentration by country, ranked highest-first.
-- Surfaces geographic skew in the customer base.
SELECT
    country,
    COUNT(customer_id) AS total_customers
FROM  gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Product catalogue depth per category.
-- Low counts may signal under-assorted categories.
SELECT
    category,
    COUNT(product_id) AS total_products
FROM  gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average unit cost per category: informs margin analysis
-- and procurement strategy at the category level.
SELECT
    category,
    AVG(cost) AS average_cost
FROM  gold.dim_products
GROUP BY category
ORDER BY average_cost DESC;

-- Category revenue contribution: drives assortment decisions
-- and highlights revenue-per-SKU efficiency gaps.
SELECT
    p.category,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products  p ON s.product_key = p.product_key
GROUP BY  p.category
ORDER BY  total_revenue DESC;

-- Revenue per customer: full roster view before any ranking.
-- Useful as a base dataset for cohort or segment analysis.
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY  c.customer_key, c.first_name, c.last_name;

-- Demand distribution by geography: total units sold per
-- country reveals shipping and inventory positioning needs.
SELECT
    c.country,
    SUM(s.quantity) AS total_sold_items
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY  c.country
ORDER BY  total_sold_items DESC;

-- ============================================================
-- SECTION 6 | RANKING ANALYSIS — TOP & BOTTOM PERFORMERS
-- Identify the highest and lowest contributors across
-- products and customers. Drives prioritisation for
-- retention, promotions, and discontinuation decisions.
-- ============================================================

-- Top 5 revenue-generating products (simple TOP N approach).
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales   s
LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 products by revenue (ascending sort, no explicit ASC
-- needed — ORDER BY defaults to ascending when DESC is absent).
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales   s
LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- ============================================================
-- Alternative: window function approach to bottom-N ranking.
-- ROW_NUMBER() inside a derived table gives stable, portable
-- rank logic that is easy to extend (e.g., RANK for ties,
-- DENSE_RANK when tie-breaking must be gap-free).
-- ============================================================
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(s.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_by_revenue
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p ON s.product_key = p.product_key
    GROUP BY p.product_name
) ranked_products
WHERE rank_by_revenue <= 5;

-- Top 10 customers by lifetime revenue: prime candidates for
-- loyalty programme targeting and churn risk monitoring.
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- 3 least-active customers by order frequency.
-- Low order counts combined with revenue data can identify
-- low-value or lapsed customers for re-engagement campaigns.
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders;
