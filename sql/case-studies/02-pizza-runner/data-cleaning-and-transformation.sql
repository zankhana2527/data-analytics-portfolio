-- Clean and transform the data
-- Create temp table in sql server by assigning # sign in front of the new table name

==============================================
-- CLEAN AND TRANSFORM customer_orders TABLE 
==============================================
DROP TABLE IF EXISTS #temp_customer_orders;
SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions = '' OR exclusions = 'null' THEN NULL
         ELSE exclusions
    END AS exclusions,
    CASE WHEN extras = '' OR extras = 'null' THEN NULL
         ELSE extras
    END AS extras,
    order_time
INTO #temp_customer_orders
FROM customer_orders;

==============================================
-- CLEAN AND TRANSFORM runner_orders TABLE 
==============================================

DROP TABLE IF EXISTS #temp_runner_orders;
SELECT
     order_id,
     runner_id,
     CASE WHEN pickup_time LIKE 'null' THEN NULL
         ELSE pickup_time
    END AS pickup_time,
     CASE WHEN distance LIKE 'null' THEN NULL
         WHEN distance LIKE '%km' THEN TRIM ('km' FROM distance)
         WHEN distance NOT LIKE '%km%' THEN distance
    END AS distance,
     CASE WHEN duration LIKE '%min%' THEN TRIM(TRAILING 'minutes ' FROM duration)
         WHEN duration LIKE 'null' THEN NULL
         WHEN duration NOT LIKE '%min%' THEN duration
    END AS duration,
     CASE WHEN cancellation LIKE 'null' OR cancellation = '' THEN NULL
         ELSE cancellation
END AS cancellation
INTO #temp_runner_orders
FROM runner_orders;
