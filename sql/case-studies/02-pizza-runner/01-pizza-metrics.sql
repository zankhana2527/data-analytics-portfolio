-- 1. How many pizzas were ordered?
SELECT
     COUNT(pizza_id) AS number_of_pizza_ordered
FROM #temp_customer_orders;

-- 2. How many unique customer orders were made?
SELECT
     COUNT(DISTINCT order_id) AS unique_orders
FROM #temp_customer_orders;

-- 3. How many successful orders were delivered by each runner?
-- Callout: dont overlook the word successful order as this requires further filtering on order status.
SELECT
     runner_id,
     COUNT(DISTINCT order_id) AS total_orders
FROM #temp_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
-- The query was giving error before casting the pizza_name column. Reason: The error occurs because the pizza_name column in your pizza_names table is defined as a text or ntext data type, which SQL Server cannot group by.
-- Permanent fix can be alterning the table with the correct datatype.
SELECT
     CAST(n.pizza_name AS VARCHAR(MAX)) AS pizza_name,
     COUNT(c.order_id) AS total_pizza
FROM #temp_customer_orders c
     JOIN #temp_runner_orders r
     ON c.order_id = r.order_id
     JOIN pizza_names n
     ON c.pizza_id = n.pizza_id
WHERE cancellation IS NULL
GROUP BY CAST(n.pizza_name AS VARCHAR(MAX));

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
     c.customer_id,
     CAST(n.pizza_name AS VARCHAR(MAX)) AS pizza_name,
     COUNT(c.order_id) AS total_pizza
FROM #temp_customer_orders c
     JOIN #temp_runner_orders r
     ON c.order_id = r.order_id
     JOIN pizza_names n
     ON c.pizza_id = n.pizza_id
GROUP BY c.customer_id, CAST(n.pizza_name AS VARCHAR(MAX));

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
     c.order_id,
     COUNT(c.pizza_id) AS number_of_pizza_ordered
FROM #temp_customer_orders c
     JOIN #temp_runner_orders r
     ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY COUNT(c.pizza_id) DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- Callout: dont overlook the word successful order as this requires further filtering on order status.
SELECT
     c.customer_id,
     SUM(CASE WHEN (c.exclusions IS NOT NULL OR c.extras IS NOT NULL) THEN 1 ELSE 0 END) AS at_least_one_change,
     SUM(CASE WHEN (c.exclusions IS NULL AND c.extras IS NULL) THEN 1 ELSE 0 END) AS no_change
FROM #temp_customer_orders c
     LEFT JOIN #temp_runner_orders r
     ON c.order_id = r.runner_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
     c.customer_id,
     SUM(CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 ELSE 0 END) AS exc_and_extras
FROM #temp_customer_orders c
     LEFT JOIN #temp_runner_orders r
     ON c.order_id = r.runner_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
     DATEPART(hour, order_time) AS hour,
     COUNT(order_id) AS total_orders_by_hour
FROM #temp_customer_orders
GROUP BY DATEPART(hour, order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT
     DATEPART(weekday, order_time) AS day_name_num,
     DATENAME(weekday, order_time) AS day_name,
     COUNT(order_id) AS total_orders_by_day
FROM #temp_customer_orders
GROUP BY DATEPART(weekday, order_time), DATENAME(weekday, order_time)
ORDER BY DATEPART(weekday, order_time);
