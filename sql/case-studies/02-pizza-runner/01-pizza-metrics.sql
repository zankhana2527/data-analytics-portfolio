-- A. Pizza Metrics

-- 1. How many pizzas were ordered?

SELECT
  COUNT(pizza_id) AS total_pizza_ordered 
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT 
  COUNT(DISTINCT order_id) AS unique_customer_orders 
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT 
  runner_id, 
  COUNT(order_id) 
FROM temp_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id; 

-- 4. How many of each type of pizza was delivered?

SELECT 
  COUNT(tco.order_id), 
  pn.pizza_name
FROM temp_customer_orders tco
JOIN pizza_names pn USING(pizza_id)
JOIN temp_runner_orders tro USING(order_id)
WHERE tro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
  tco.customer_id, 
  COUNT(tco.pizza_id), 
  pn.pizza_name
FROM  temp_customer_orders tco
JOIN pizza_names pn
USING(pizza_id)
GROUP BY tco.pizza_id, pn.pizza_name, tco.customer_id
ORDER BY tco.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT 
  order_id, 
  COUNT(pizza_id) AS count 
FROM temp_customer_orders
GROUP BY order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
	tco.customer_id,
    SUM(CASE WHEN (tco.exclusions IS NOT NULL OR tco.extras IS NOT NULL) THEN 1 ELSE 0 END) AS at_least_one_change,
    SUM(CASE WHEN (tco.exclusions IS NULL AND tco.extras IS NULL) THEN 1 ELSE 0 END) AS no_change
FROM temp_customer_orders tco
JOIN temp_runner_orders tro
USING(order_id)
WHERE tro.cancellation IS NULL
GROUP BY tco.customer_id
ORDER BY tco.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
  tco.customer_id, 
  SUM(CASE WHEN (tco.exclusions IS NOT NULL AND tco.extras IS NOT NULL) THEN 1 ELSE 0 END) AS total_delivered_pizza_with_exclusions_and_extras
FROM temp_customer_orders tco
JOIN temp_runner_orders tro
USING(order_id)
WHERE tro.cancellation IS NULL
GROUP BY tco.customer_id

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
	EXTRACT(hour from order_time) AS hour,
    COUNT(pizza_id)
FROM temp_customer_orders
GROUP BY hour
ORDER BY hour;

-- 10. What was the volume of orders for each day of the week?

SELECT 
	EXTRACT(dow from order_time) AS day,
	COUNT(pizza_id)
FROM temp_customer_orders
GROUP BY day
ORDER BY day;
