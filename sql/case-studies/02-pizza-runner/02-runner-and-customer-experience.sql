-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    ((registration_date - '2021-01-01') / 7) + 1 AS week,
    COUNT(runner_id) AS total_runners
FROM runners
GROUP BY week
ORDER BY week;
-- Using EXTRACT(week from registration_date) gives week number 53 due to the ISO numbering system by default.

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
    tro.runner_id,
    ROUND(AVG(EXTRACT(EPOCH FROM (tro.pickup_time::TIMESTAMP - tco.order_time::TIMESTAMP)) / 60)::NUMERIC, 2) AS avg_time
    
	-- tco.order_id, 
	-- tco.order_time, 
	-- tro.pickup_time,
	-- (tro.pickup_time::TIMESTAMP - tco.order_time::TIMESTAMP) AS difference,
	-- EXTRACT(EPOCH FROM (tro.pickup_time::TIMESTAMP - tco.order_time::TIMESTAMP)) / 60 AS minutes
    
FROM temp_customer_orders tco
JOIN temp_runner_orders tro
USING(order_id)
WHERE tro.cancellation IS NULL
GROUP BY tro.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH order_count_cte AS (SELECT
	tco.order_id,
	COUNT(pizza_id) AS count,
    tco.order_time,
    tro.pickup_time,
    EXTRACT(EPOCH FROM (tro.pickup_time::TIMESTAMP - tco.order_time::TIMESTAMP)) / 60 AS difference
FROM temp_customer_orders tco
JOIN temp_runner_orders tro
USING(order_id)
WHERE tco.order_id IS NOT NULL ANd tro.pickup_time IS NOT NULL AND tro.cancellation IS NULL
GROUP BY tco.order_id, tco.order_time, tro.pickup_time
ORDER BY order_id)

SELECT
	count,
    ROUND(AVG(difference)::NUMERIC, 2) AS avr_prep_time
FROM order_count_cte
GROUP BY count;

-- 4. What was the average distance travelled for each customer?

SELECT
	tco.customer_id,
    ROUND(AVG(distance)::NUMERIC, 2) AS avg_distance
FROM temp_customer_orders tco
JOIN temp_runner_orders tro
USING(order_id)
WHERE tro.cancellation IS NULL
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
	MAX(duration) - MIN(duration) AS difference
FROM temp_runner_orders

6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	runner_id,
    order_id,
    distance::NUMERIC AS distance_in_km,
    ROUND(duration::NUMERIC/60, 2) AS duration_in_hr,
    ROUND(distance::NUMERIC*60/duration::NUMERIC, 2) AS speed
FROM temp_runner_orders
WHERE distance IS NOT NULL AND duration IS NOT NULL AND cancellation IS NULL
ORDER BY runner_id, order_id;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
    COUNT(*) AS total_orders,
    COUNT(pickup_time) AS delivered_orders,
    (COUNT(pickup_time) * 100 /COUNT(*)) AS success_rate
FROM temp_runner_orders
GROUP BY runner_id;
ORDER BY runner_id;
