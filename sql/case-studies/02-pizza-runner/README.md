# Case Study 2: Pizza Runner

A compact SQL project exploring customer ordering behavior, pizza customizations, delivery metrics, and runner performance.


## Questions & SQL Queries
### Data Cleaning and Transformation
```sql
-- Clean and transform the data
-- Create temp table in sql server by assigning # sign in front of the new table name

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
```
```sql
-- Clean and transform the data
-- Create temp table in sql server by assigning # sign in front of the new table name

DROP TABLE IF EXISTS #temp_runner_orders;
SELECT
    order_id,
    runner_id,
    CASE WHEN pickup_time LIKE 'null' THEN NULL
         ELSE pickup_time
    END AS pickup_time,
    CASE WHEN distance LIKE 'null' THEN NULL
         WHEN distance LIKE '%km' THEN TRIM ('km' FROM distance)
    END AS distance,
    CASE WHEN duration LIKE '%min%' THEN TRIM(TRAILING 'minutes ' FROM duration)
         WHEN duration LIKE 'null' THEN NULL
    END AS duration,
    CASE WHEN cancellation LIKE 'null' OR cancellation = '' THEN NULL
         ELSE cancellation
END AS cancellation
INTO #temp_runner_orders
FROM runner_orders;
```
### Pizza Metrics
#### 1. How many pizzas were ordered?

#### 2. How many unique customer orders were made?

#### 3. How many successful orders were delivered by each runner?

#### 4. How many of each type of pizza was delivered?

#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

#### 6. What was the maximum number of pizzas delivered in a single order?

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

#### 8. How many pizzas were delivered that had both exclusions and extras?

#### 9. What was the total volume of pizzas ordered for each hour of the day?

#### 10. What was the volume of orders for each day of the week?
