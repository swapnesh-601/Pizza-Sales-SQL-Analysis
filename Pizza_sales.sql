DROP TABLE IF EXISTS pizzas;
DROP TABLE IF EXISTS pizza_types;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_details;

CREATE TABLE pizzas (
    pizza_id VARCHAR(50),
    pizza_type_id VARCHAR(50),
    size VARCHAR(5),
    price VARCHAR(20)
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50),
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients VARCHAR(500)
);

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM orders;
SELECT * FROM order_details;

--BASIC
--Retrieve the total number of orders placed.
SELECT COUNT(order_id)  AS total_orders
FROM orders;

--Calculate the total revenue generated from pizza sales.
SELECT ROUND(
    SUM(order_details.quantity * CAST(pizzas.price AS NUMERIC)),
    2
) AS total_sales
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id;

--Identify the highest-priced pizza.
SELECT pizza_types.name ,
CAST(pizzas.price AS NUMERIC)
FROM pizza_types
JOIN
pizzas
ON
pizzas.pizza_type_id=pizza_types.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;

--Identify the most common pizza size ordered.
SELECT pizzas.size,
COUNT(order_details.order_details_id)
FROM pizzas
JOIN 
order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC;  


--List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
COUNT(order_details.quantity)
FROM pizza_types
JOIN
pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN
order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category ,
SUM(order_details.quantity)
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN
order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

--Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time) AS Hour ,
COUNT(order_id) AS order_count
FROM orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY 2 DESC;

--Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,
COUNT(name)
FROM pizza_types
GROUP BY category;

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity),0) FROM
(SELECT orders.order_date,
SUM(order_details.quantity) AS quantity
FROM orders
JOIN
order_details
ON orders.order_id=order_details.order_id
GROUP BY orders.order_date ) AS order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
SUM(order_details.quantity*pizzas.price::NUMERIC)
FROM pizzas
JOIN pizza_types
ON pizzas.pizza_type_id=pizza_types.pizza_type_id
JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY 2 DESC
LIMIT 3;

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price::NUMERIC) * 100.0 /
        (
            SELECT SUM(order_details.quantity * pizzas.price::NUMERIC)
            FROM order_details
            JOIN pizzas
                ON order_details.pizza_id = pizzas.pizza_id
        ),
        2
    ) AS revenue_percentage
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

 --Analyze the cumulative revenue generated over time.
 SELECT order_date,SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
 FROM
 (SELECT orders.order_date,
 SUM(order_details.quantity*pizzas.price::NUMERIC) AS revenue
 FROM order_details
 JOIN pizzas
 ON order_details.pizza_id=pizzas.pizza_id
 JOIN orders
 ON orders.order_id=order_details.order_id
 GROUP BY 1) AS sales;

 --Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 SELECT name,
 revenue
 FROM
(SELECT category,
name,
revenue,RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category,
pizza_types.name,
SUM(order_details.quantity*pizzas.price::NUMERIC) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY 1,2) AS a) AS b
WHERE rn <=3;
 
 
























































