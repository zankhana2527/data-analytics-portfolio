-- Case Study #1 - Danny's Diner
-- Schema Setup: DDL & DML

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  s.customer_id,
  m.product_name,
  SUM(m.price) as total_spent
FROM sales s
LEFT JOIN menu m
USING(product_id)
GROUP BY s.customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT
  customer_id,
  COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH first_item_cte AS (SELECT
  s.customer_id, m.product_name,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM sales s
LEFT JOIN menu m
USING (product_id))

SELECT DISTINCT customer_id, product_name FROM first_item_cte
WHERE rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
  m.product_name, COUNT(s.product_id) AS product_count
FROM sales s
LEFT JOIN menu m
USING (product_id)
GROUP BY product_id
ORDER BY product_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH ranked_products AS (SELECT
  customer_id,
  product_name,
  COUNT(product_id) AS product_count,
  RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rank
FROM sales s
LEFT JOIN menu m
USING (product_id)
GROUP BY customer_id, product_id)

SELECT
  customer_id, 
  product_name, 
  product_count 
FROM ranked_products
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
FROM sales s
INNER JOIN members mem
USING (customer_id)
INNER JOIN menu m
USING(product_id)
WHERE s.order_date >= mem.join_date)

SELECT
  customer_id, 
  product_name,
  order_date,
  join_date
FROM ranked_products
WHERE rank = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date,
  RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank
FROM sales s
INNER JOIN members mem
USING (customer_id)
INNER JOIN menu m
USING(product_id)
WHERE s.order_date < mem.join_date)

SELECT 
  customer_id,
  product_name, 
  order_date, 
  join_date 
FROM ranked_products
WHERE rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?

WITH ranked_products AS (SELECT
  s.customer_id, m.product_name, s.order_date, mem.join_date, m.price
FROM sales s
INNER JOIN members mem
USING (customer_id)
INNER JOIN menu m
USING(product_id)
WHERE s.order_date < mem.join_date)

SELECT
  customer_id,
  COUNT(product_name),
  SUM(price)
FROM ranked_products
GROUP BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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
USING (product_id))

SELECT 
  customer_id,
  SUM(points) as total_points
FROM points_cte
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- REVIEW

WITH points_cte AS (SELECT
  s.customer_id, 
  m.product_name,
  m.price,
  m.price*10*2 AS points
FROM sales s
INNER JOIN members mem
USING (customer_id)
INNER JOIN menu m
USING (product_id)
WHERE s.order_date BETWEEN mem.join_date AND date(mem.join_date, '+7 days'))

SELECT customer_id, product_name, SUM(points)
FROM points_cte
GROUP BY customer_id
