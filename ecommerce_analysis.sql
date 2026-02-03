CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

SET GLOBAL local_infile = 1;

-- Orders Table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Order Items Table
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price FLOAT,
    freight_value FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ANALYSIS QUERIES
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

SELECT 
    customer_state, COUNT(*)
FROM
    customers
GROUP BY customer_state;

SELECT 
    SUM(price) AS total_revenue
FROM
    order_items;

#__________________________________________________________________________________
TRUNCATE TABLE order_items;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 
    COUNT(*)
FROM
    order_items;
SELECT 
    *
FROM
    order_items
LIMIT 5;
SELECT 
    SUM(price)
FROM
    order_items;

SELECT DISTINCT
    customer_city
FROM
    customers;
SELECT 
    COUNT(*) AS orders_2017
FROM
    orders
WHERE
    order_purchase_timestamp LIKE '2017%';
SELECT 
    SUM(price) AS total_revenue
FROM
    order_items;
SELECT 
    customer_state, COUNT(*) AS total_customers
FROM
    customers
GROUP BY customer_state
ORDER BY total_customers DESC;
SELECT 
    c.customer_id, COUNT(o.order_id) AS total_orders
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_orders DESC
LIMIT 10

SELECT 
    SUBSTRING(order_purchase_timestamp,
        1,
        7) AS order_month,
    COUNT(*) AS total_orders
FROM
    orders
GROUP BY order_month
ORDER BY order_month;

SELECT 
    AVG(price) AS avg_order_value
FROM
    order_items;

SELECT 
    o.customer_id, SUM(oi.price) AS total_spent
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

SELECT 
    SUBSTRING(o.order_purchase_timestamp,
        1,
        7) AS order_month,
    SUM(oi.price) AS monthly_revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

SELECT 
    AVG(product_count) AS avg_products_per_order
FROM
    (SELECT 
        order_id, COUNT(*) AS product_count
    FROM
        order_items
    GROUP BY order_id) AS temp;

SELECT 
    seller_id, SUM(price) AS seller_revenue
FROM
    order_items
GROUP BY seller_id
ORDER BY seller_revenue DESC
LIMIT 10;

