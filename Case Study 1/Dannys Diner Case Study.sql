-- SOURCE: 	8 Week SQL Challenge from Danny Ma
-- TOPIC: 		Case Study 1 - Dannys Diner
-- AUTHOR: 	Hemprakash P
-- TOOL: 		MySQL

########################################################################################################################

CREATE DATABASE IF NOT EXISTS dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
customer_id VARCHAR(1),
order_date DATE,
product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
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
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
########################################################################################################################

SELECT * FROM sales;  -- 15 Rows
SELECT * FROM members; -- 2 Rows
SELECT * FROM menu; -- 3 Rows

########################################################################################################################

-- Case Study Question 1:
-- What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id, 
	SUM(price) AS total_spent
FROM 	sales s
JOIN menu m 
	USING(product_id)
GROUP BY customer_id;

########################################################################################################################

-- Case Study Question 2:
-- How many days has each customer visited the restaurant?

SELECT 
	customer_id,
    COUNT( DISTINCT order_date) AS visits
FROM sales
GROUP BY customer_id;

########################################################################################################################

-- Case Study Question 3:
-- What was the first item from the menu purchased by each customer?

WITH cte1 AS (SELECT 
							customer_id, 
							product_id, order_date,
							DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk 
						FROM sales)

SELECT 
	cte1.customer_id, cte1.product_id, order_date, m.product_name
FROM cte1
JOIN menu m
	ON cte1.product_id = m.product_id
WHERE cte1.rnk=1;

########################################################################################################################

-- Case Study Question 4:
-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	s.product_id, product_name AS most_ordered_product,
	COUNT(order_date) AS total_orders 
FROM sales s 
JOIN menu m
	on s.product_id = m.product_id
GROUP BY product_id 
ORDER BY total_orders DESC
LIMIT 1;

########################################################################################################################

-- Case Study Question 5:
-- Which item was the most popular for each customer?

WITH cte1 AS (
						SELECT 
							s.customer_id, 
							s.product_id, 
							m.product_name,
							COUNT(s.product_id) AS purchases,
							DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC) AS rnk
						FROM sales s
						JOIN menu m
							on s.product_id = m.product_id
						GROUP BY customer_id, product_id 
						ORDER BY customer_id ASC, purchases DESC
					  )

SELECT 
	customer_id, 
	GROUP_CONCAT(product_name) AS most_popular_item 
FROM cte1 
	WHERE cte1.rnk=1 
GROUP BY customer_id;

########################################################################################################################

-- Case Study Question 6:
-- Which item was purchased first by the customer after they became a member?

WITH cte1 AS (
						SELECT 
							s.customer_id, 
							s.order_date, 
							mm.join_date AS membership_date, 
							m.product_name,
							DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, order_date) AS rnk
						FROM sales s 
						JOIN members mm 
							ON s.customer_id = mm.customer_id AND s.order_date>=mm.join_date
						JOIN menu m 
							ON s.product_id = m.product_id)
                            
SELECT customer_id, product_name AS first_purchased_product_after_membership 
FROM cte1
WHERE cte1.rnk = 1;

########################################################################################################################

-- Case Study Question 7:
-- Which item was purchased just before the customer became a member?

WITH cte1 AS (
						SELECT 
							s.customer_id, 
							s.order_date, 
							mm.join_date AS membership_date, 
							m.product_name,
							DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, order_date DESC) AS rnk
						FROM sales s 
						JOIN members mm 
							ON s.customer_id = mm.customer_id AND s.order_date<mm.join_date
						JOIN menu m 
							ON s.product_id = m.product_id)
                            
SELECT customer_id, GROUP_CONCAT(product_name) AS last_purchased_product_just_before_membership 
FROM cte1
WHERE cte1.rnk = 1
GROUP BY customer_id;

########################################################################################################################

-- Case Study Question 8:
-- What is the total items and amount spent for each member before they became a member?

SELECT 
	s.customer_id,
    COUNT(DISTINCT s.product_id) AS unique_items_ordered,
    SUM(m.price) AS total_amount_spent
FROM sales s
JOIN members mm
	ON s.customer_id = mm.customer_id 
		AND s.order_date<mm.join_date
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;

########################################################################################################################

-- Case Study Question 9:
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	s.customer_id,
    SUM(CASE WHEN m.product_name = 'sushi' 
			THEN 20*price ELSE 10*price END) AS points
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;

########################################################################################################################

-- Case Study Question 10:
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Steps
-- 1. Filtered sales that took place in January alone
-- 2. Points start accumulating only after becoming a member. So purchases before that don't count towards points calculation.

WITH cte1 AS (
						SELECT 
							s.customer_id,
							s.order_date, 
							s.product_id,
							CASE 
								WHEN order_date BETWEEN join_date AND date_add(join_date, INTERVAL 6 DAY)
								THEN 'first_week' ELSE 'normal_days' END AS week_category,
							m.product_name,
							m.price
						FROM sales s
						JOIN members mm
							ON s.customer_id = mm.customer_id AND s.order_date>=mm.join_date
						JOIN menu m
							ON s.product_id = m.product_id
						WHERE month(order_date) =1 
						ORDER BY customer_id, order_date)

SELECT
	customer_id, 
    SUM(CASE 
		WHEN week_category = 'first_week' THEN price*20
        WHEN week_category = 'normal_days' AND product_name = 'sushi' THEN price*20 ELSE price*10
	END) AS points
FROM cte1
GROUP BY customer_id
ORDER BY customer_id;

