-- ============================================================
-- Part-to-Whole Analysis: Category Contribution to Total Sales
-- Source: gold.fact_sales, gold.dim_products
-- ============================================================

-- Aggregate total sales per product category
WITH category_cte AS (
	SELECT
		p.category,
		SUM(s.sales_amount) AS total_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		ON s.product_key = p.product_key
	GROUP BY p.category
)

-- Calculate each category's share of overall sales
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_total
FROM category_cte
ORDER BY total_sales DESC;
