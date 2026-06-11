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
```sql
SELECT
     COUNT(pizza_id) AS number_of_pizza_ordered
FROM #temp_customer_orders;
```
    number_of_pizza_ordered
    -----------------------
    14  
    
#### 2. How many unique customer orders were made?
```sql
SELECT
     COUNT(DISTINCT order_id) AS unique_orders
FROM #temp_customer_orders;
```
    unique_orders
    -------------
    10  

#### 3. How many successful orders were delivered by each runner?
```sql
-- Callout: dont overlook the word successful order as this requires further filtering on order status.
SELECT
     runner_id,
     COUNT(DISTINCT order_id) AS total_orders
FROM #temp_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
```
    runner_id   total_orders
    ----------  ------------
    1           4           
    2           3           
    3           1    
    
#### 4. How many of each type of pizza was delivered?
```sql
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
```

    pizza_name  total_pizza
    ----------  -----------
    Meatlovers  9          
    Vegetarian  3  
    
#### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
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
```

    customer_id  pizza_name  total_pizza
    -----------  ----------  -----------
    101          Meatlovers  2          
    101          Vegetarian  1          
    102          Meatlovers  2          
    102          Vegetarian  1          
    103          Meatlovers  3          
    103          Vegetarian  1          
    104          Meatlovers  3          
    105          Vegetarian  1  

#### 6. What was the maximum number of pizzas delivered in a single order?
```sql
SELECT
     c.order_id,
     COUNT(c.pizza_id) AS number_of_pizza_ordered
FROM #temp_customer_orders c
     JOIN #temp_runner_orders r
     ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY COUNT(c.pizza_id) DESC;
```
    order_id    number_of_pizza_ordered
    ----------  -----------------------
    4           3                      
    3           2                      
    10          2                      
    1           1                      
    2           1                      
    5           1                      
    7           1                      
    8           1   

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
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
```
    customer_id  at_least_one_change  no_change 
    -----------  -------------------  ----------
    101          0                    8         
    102          0                    3         
    103          4                    0         
    104          2                    1         
    105          1                    0        

#### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT
     c.customer_id,
     SUM(CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 ELSE 0 END) AS exc_and_extras
FROM #temp_customer_orders c
     LEFT JOIN #temp_runner_orders r
     ON c.order_id = r.runner_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;
```

    customer_id  exc_and_extras
    -----------  --------------
    101          0             
    102          0             
    103          1             
    104          1             
    105          0       

#### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT
     DATEPART(hour, order_time) AS hour,
     COUNT(order_id) AS total_orders_by_hour
FROM #temp_customer_orders
GROUP BY DATEPART(hour, order_time);
```

    hour        total_orders_by_hour
    ----------  --------------------
    11          1                   
    13          3                   
    18          3                   
    19          1                   
    21          3                   
    23          3      

#### 10. What was the volume of orders for each day of the week?
```sql
SELECT
     DATEPART(weekday, order_time) AS day_name_num,
     DATENAME(weekday, order_time) AS day_name,
     COUNT(order_id) AS total_orders_by_day
FROM #temp_customer_orders
GROUP BY DATEPART(weekday, order_time), DATENAME(weekday, order_time)
ORDER BY DATEPART(weekday, order_time);
```
    day_name_num  day_name    total_orders_by_day
    ------------  ----------  -------------------
    4             Wednesday   5                  
    5             Thursday    3                  
    6             Friday      1                  
    7             Saturday    5                  
