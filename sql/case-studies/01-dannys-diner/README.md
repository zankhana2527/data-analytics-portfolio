# Case Study 1: Danny's Diner

A compact SQL project exploring customer behavior, spending patterns, and membership activity at Danny’s Diner.

## Questions & SQL Queries
#### 1. What is the total amount each customer spent at the restaurant?
```sql
SELECT
  s.customer_id,
  m.product_name,
  SUM(m.price) AS total_spent
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
```
#### 2. How many days has each customer visited the restaurant?
```sql
SELECT
  customer_id,
  COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id;
```
#### 3. What was the first item from the menu purchased by each customer?
```sql
WITH first_item_cte AS (SELECT
  s.customer_id, m.product_name,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id)

SELECT
  DISTINCT customer_id,
  product_name
FROM first_item_cte
WHERE rank = 1;
```
#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT
  m.product_name, COUNT(s.product_id) AS product_count
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_id
ORDER BY product_count DESC
LIMIT 1;
```
#### 5. Which item was the most popular for each customer?
```sql
WITH ranked_products AS (SELECT
  customer_id,
  product_name,
  COUNT(product_id) AS product_count,
  RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rank
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_id)

SELECT
  customer_id, 
  product_name, 
  product_count 
FROM ranked_products
WHERE rank = 1;
```
#### 6. Which item was purchased first by the customer after they became a member?
```sql
WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
FROM sales s
INNER JOIN members mem
ON s.customer_id = mem.customer_id
INNER JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date >= mem.join_date)

SELECT
  customer_id, 
  product_name,
  order_date,
  join_date
FROM ranked_products
WHERE rank = 1;
```
#### 7. Which item was purchased just before the customer became a member?
```sql
WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
FROM sales s
INNER JOIN members mem
ON s.customer_id = mem.customer_id
INNER JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date)

SELECT 
  customer_id,
  product_name, 
  order_date, 
  join_date 
FROM ranked_products
WHERE rank = 1
```
#### 8. What is the total items and amount spent for each member before they became a member?
```sql
WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date, m.price
FROM sales s
INNER JOIN members mem
ON s.customer_id = mem.customer_id
INNER JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date)

SELECT
  customer_id,
  COUNT(product_name),
  SUM(price)
FROM   ranked_products
GROUP BY customer_id;
```
#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
WITH points_cte AS (SELECT 
  s.customer_id,
  m.product_name,
  m.price,
  CASE
  WHEN m.product_name = 'sushi' THEN m.price*10*2
  ELSE m.price*10
  END AS points
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id)

SELECT 
  customer_id,
  SUM(points) as total_points
FROM points_cte
GROUP BY customer_id;
```
#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
WITH points_cte AS (SELECT
  s.customer_id, 
  m.product_name,
  m.price,
  m.price*10*2 AS points
FROM sales s
INNER JOIN members mem
ON s.customer_id = mem.customer_id
INNER JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date BETWEEN mem.join_date AND date(mem.join_date, '+7 days'))

SELECT customer_id, product_name, SUM(points)
FROM points_cte
GROUP BY customer_id
```
## Reflection

This case study helped me practice turning raw transaction data into business insight. It also improved my ability to combine joins, ranking, and conditional logic in one analysis.
