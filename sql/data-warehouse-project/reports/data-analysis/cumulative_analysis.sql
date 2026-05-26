-- ============================================================
-- Cumulative Analysis: Running Total & Moving Average
-- Source: gold.fact_sales
-- ============================================================

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_sales,        -- running total (unbounded preceding → current row)
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_average          -- cumulative avg price over time
FROM (
	-- Aggregate sales and average price at monthly granularity
	SELECT
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
) t
