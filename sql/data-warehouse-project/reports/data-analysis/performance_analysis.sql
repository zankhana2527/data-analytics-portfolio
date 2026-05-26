-- ============================================================
-- Performance Analysis: Product Sales vs. Historical Avg & YoY
-- Source: gold.fact_sales, gold.dim_products
-- ============================================================

-- Annual sales revenue per product
WITH sales_cte AS (
	SELECT
		YEAR(s.order_date) AS order_year,
		p.product_name,
		SUM(s.sales_amount) AS current_sale
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.product_name
)

-- Benchmark each year against the product's historical avg and prior year sales
SELECT
	order_year,
	product_name,
	current_sale,
	AVG(current_sale) OVER(PARTITION BY product_name) AS avg_sales,
	current_sale - AVG(current_sale) OVER(PARTITION BY product_name) AS avg_diff,
	CASE WHEN current_sale - AVG(current_sale) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		 WHEN current_sale - AVG(current_sale) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		 ELSE 'Avg'
	END AS avg_flag,
	LAG(current_sale) OVER(PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
	current_sale - LAG(current_sale) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_prev_year_sale,
	CASE WHEN current_sale - LAG(current_sale) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 WHEN current_sale - LAG(current_sale) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	END AS sale_diff_flag
FROM sales_cte
ORDER BY product_name, order_year;
