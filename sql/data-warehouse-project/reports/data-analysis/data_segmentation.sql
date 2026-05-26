-- ============================================================
-- Data Segmentation: Products by Cost Range & Customers by Value
-- Source: gold.dim_products, gold.fact_sales, gold.dim_customers
-- ============================================================

-- Segment products by cost range and count per segment
WITH product_seg_cte AS (
	SELECT
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
			 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			 ELSE 'Above 1000'
		END AS cost_segment
	FROM gold.dim_products
)

SELECT
	cost_segment,
	COUNT(product_key) AS product_count
FROM product_seg_cte
GROUP BY cost_segment
ORDER BY product_count DESC;


-- Segment customers by lifespan and total spending (VIP / Regular / New)
WITH customer_segment_cte AS (
	SELECT
		c.customer_key,
		SUM(s.sales_amount) AS total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON s.customer_key = c.customer_key
	GROUP BY c.customer_key
)

SELECT
	segment,
	COUNT(customer_key) AS total_customers
FROM (
	SELECT
		customer_key,
		total_spending,
		lifespan,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS segment
	FROM customer_segment_cte
) t
GROUP BY segment
ORDER BY total_customers DESC;
