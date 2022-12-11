-- SOURCE:	8 Week SQL Challenge from Danny Ma
-- TOPIC:	 	Case Study #2 Pizza Runner (A. Pizza Metrics)
-- AUTHOR:	Hemprakash P
-- TOOL:		MySQL

USE pizzarunner;

########################################################################################################################

-- Pizza Metrics Question 1
-- How many pizzas were ordered?

SELECT
	COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders;

########################################################################################################################

-- Pizza Metrics Question 2
-- How many unique customer orders were made?

SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;

########################################################################################################################

-- Pizza Metrics Question 3
-- How many successful orders were delivered by each runner?

SELECT 
	runner_id,
	COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE distance NOT LIKE '%null%'
GROUP BY runner_id;

########################################################################################################################

-- Pizza Metrics Question 4
-- How many of each type of pizza was delivered?

SELECT 
	c.pizza_id,
    COUNT(c.pizza_id) AS deliveries
FROM customer_orders c
JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.distance NOT LIKE '%null%'
GROUP BY c.pizza_id;

########################################################################################################################

-- Pizza Metrics Question 5
-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	c.customer_id,
    pn.pizza_name,
    COUNT(c.pizza_id) AS qty
FROM customer_orders c
JOIN pizza_names pn
	ON c.pizza_id = pn.pizza_id
GROUP BY c.customer_id, pn.pizza_name
ORDER BY c.customer_id, pn.pizza_name;

########################################################################################################################

-- Pizza Metrics Question 6
-- What was the maximum number of pizzas delivered in a single order?

-- STEPS:
-- Find orders that are delivered
-- Then Group pizza_id with count
-- Find the max

WITH cte1 AS (
						SELECT order_id, COUNT(pizza_id) AS cnt 
						FROM customer_orders 
						WHERE order_id IN (SELECT DISTINCT order_id FROM runner_orders 
                                                       WHERE distance NOT LIKE '%null%')
						GROUP BY order_id ORDER BY cnt DESC)
                        
SELECT 
	order_id, 
    cnt AS max_pizza_delivered
FROM cte1
WHERE cnt = (SELECT MAX(cnt) FROM cte1);

########################################################################################################################

-- Pizza Metrics Question 7
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- STEPS:
-- Find orders that are delivered
-- USE case statements to sum pizzas with and without changes (i.e., exclusions)







































 
 
 
 
 