-- ============================================================
-- Plato's Pizza Sales Analysis
-- Author: Rohit Singh Bisht
-- Database: MySQL
-- Dataset: Maven Analytics Pizza Sales (2015)
-- ============================================================


-- ============================================================
-- SECTION 1: CREATE DATABASE
-- ============================================================

DROP DATABASE IF EXISTS pizza_sales;
CREATE DATABASE pizza_sales;
USE pizza_sales;


-- ============================================================
-- SECTION 2: CREATE TABLES
-- ============================================================

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50),
    size VARCHAR(5),
    price DECIMAL(5,2),
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id)
);


-- ============================================================
-- SECTION 3: IMPORT CSV DATA
-- ============================================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizza_types.csv'
INTO TABLE pizza_types
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pizza_type_id,name,category,ingredients);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizzas.csv'
INTO TABLE pizzas
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pizza_id,pizza_type_id,size,price);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id,date,time);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_details_id,order_id,pizza_id,quantity);



-- ============================================================
-- SECTION 4: DATA VALIDATION
-- ============================================================

-- Row counts
SELECT COUNT(*) FROM pizza_types;
SELECT COUNT(*) FROM pizzas;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_details;

-- Check for NULL values
SELECT
SUM(order_id IS NULL) AS null_order_id,
SUM(date IS NULL) AS null_date,
SUM(time IS NULL) AS null_time
FROM orders;

SELECT
SUM(order_details_id IS NULL) AS null_detail_id,
SUM(order_id IS NULL) AS null_order_id,
SUM(pizza_id IS NULL) AS null_pizza_id,
SUM(quantity IS NULL) AS null_quantity
FROM order_details;

-- Invalid quantities
SELECT COUNT(*) 
FROM order_details
WHERE quantity <= 0;

-- Date range
SELECT MIN(date), MAX(date)
FROM orders;



-- ============================================================
-- SECTION 5: KEY BUSINESS METRICS
-- ============================================================

-- Total Revenue
SELECT
SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Average Order Value
SELECT
ROUND(SUM(od.quantity * p.price) /
COUNT(DISTINCT o.order_id),2) AS avg_order_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id;



-- ============================================================
-- SECTION 6: BUSIEST TIMES
-- ============================================================

-- Busiest Hour
SELECT
HOUR(time) AS hour_of_day,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY hour_of_day
ORDER BY total_orders DESC;

-- Busiest Day
SELECT
DAYNAME(date) AS day_of_week,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY total_orders DESC;



-- ============================================================
-- SECTION 7: PIZZAS PRODUCED DURING PEAK HOURS
-- ============================================================

SELECT
HOUR(o.time) AS hour,
SUM(od.quantity) AS pizzas_made
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY hour
ORDER BY pizzas_made DESC;



-- ============================================================
-- SECTION 8: PRODUCT PERFORMANCE
-- ============================================================

-- Best selling pizzas
SELECT
pt.name,
SUM(od.quantity) AS pizzas_sold
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY pizzas_sold DESC
LIMIT 10;


-- Worst selling pizzas
SELECT
pt.name,
SUM(od.quantity) AS pizzas_sold
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY pizzas_sold ASC
LIMIT 10;



-- ============================================================
-- SECTION 9: REVENUE ANALYSIS
-- ============================================================

-- Revenue by category
SELECT
pt.category,
ROUND(SUM(od.quantity * p.price),2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- Revenue by pizza size
SELECT
p.size,
ROUND(SUM(od.quantity * p.price),2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;



-- ============================================================
-- SECTION 10: MONTHLY SALES TREND
-- ============================================================

SELECT
MONTH(date) AS month_num,
MONTHNAME(date) AS month,
ROUND(SUM(od.quantity * p.price),2) AS monthly_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTH(date),MONTHNAME(date)
ORDER BY month_num;



-- ============================================================
-- SECTION 11: KITCHEN WORKLOAD
-- ============================================================

-- Average pizzas produced per hour
SELECT
HOUR(o.time) AS hour_of_day,
ROUND(SUM(od.quantity) /
COUNT(DISTINCT o.date),2) AS avg_pizzas_per_day_at_hour
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY hour_of_day
ORDER BY avg_pizzas_per_day_at_hour DESC;



-- ============================================================
-- SECTION 12: CUSTOMER BEHAVIOR
-- ============================================================

-- Average pizzas per order
SELECT
ROUND(SUM(quantity) /
COUNT(DISTINCT order_id),2) AS avg_pizzas_per_order
FROM order_details;

-- Average pizzas per day
SELECT
ROUND(SUM(quantity)/365,2) AS avg_pizzas_per_day
FROM order_details;