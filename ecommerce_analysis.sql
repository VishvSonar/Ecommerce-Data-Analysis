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
SELECT DISTINCT
    customer_city
FROM
    customers;

SELECT 
    COUNT(*)
FROM
    orders
WHERE
    order_purchase_timestamp LIKE '2017%';

#3.Total Sales Per Category
SHOW COLUMNS FROM products;
SELECT 
    p.`product category`, SUM(oi.price) AS total_sales
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.`product category`
ORDER BY total_sales DESC;


SELECT 
    ROUND((COUNT(DISTINCT CASE
                    WHEN payment_installments > 1 THEN order_id
                END) * 100.0) / COUNT(DISTINCT order_id),
            2) AS installment_percentage
FROM
    order_payments;

SELECT 
    customer_state, COUNT(customer_id) AS total_customers
FROM
    customers
GROUP BY customer_state
ORDER BY total_customers DESC;
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2018
GROUP BY order_month
ORDER BY order_month;

SELECT 
    c.customer_city, AVG(order_product_count) AS avg_products
FROM
    (SELECT 
        order_id, COUNT(product_id) AS order_product_count
    FROM
        order_items
    GROUP BY order_id) oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_city;

SELECT 
    p.`product category`,
    ROUND(SUM(oi.price) * 100 / (SELECT 
                    SUM(price)
                FROM
                    order_items),
            2) AS revenue_percent
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.`product category`
ORDER BY revenue_percent DESC;

SELECT 
    product_id,
    AVG(price) AS avg_price,
    COUNT(order_id) AS purchase_count
FROM
    order_items
GROUP BY product_id;

#5.Total Revenue per Seller & Ranking
SELECT 
    seller_id,
    SUM(price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items
GROUP BY seller_id;

#-----------------------------------------------------------------ADVANCE PROBLEMS-----------------------------------------------------------------------------

#1. Moving Average of Order Value per Customer
SELECT
    customer_id,
    order_purchase_timestamp,
    payment_value,
    AVG(payment_value) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_value
FROM orders o
JOIN order_payments p
ON o.order_id = p.order_id;

#2.Calculate the cumulative sales per month for each year
DESCRIBE orders;

ALTER TABLE orders
MODIFY order_purchase_timestamp DATETIME;

SELECT
    year,
    month,
    monthly_sales,
    SUM(monthly_sales) OVER (
        PARTITION BY year
        ORDER BY month
    ) AS cumulative_sales
FROM (
    SELECT
        YEAR(o.order_purchase_timestamp) AS year,
        MONTH(o.order_purchase_timestamp) AS month,
        SUM(p.payment_value) AS monthly_sales
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY year, month
) t
ORDER BY year, month;


#3.Year-over-Year Growth Rate
WITH yearly AS (
  SELECT
    YEAR(order_purchase_timestamp) AS yr,
    SUM(payment_value) AS total_sales
  FROM orders o
  JOIN order_payments p
  ON o.order_id = p.order_id
  GROUP BY yr
)
SELECT
  yr,
  total_sales,
  (total_sales - LAG(total_sales) OVER (ORDER BY yr))
  / LAG(total_sales) OVER (ORDER BY yr) * 100 AS yoy_growth
FROM yearly;

#4. Customer Retention Rate (6 Months)
WITH first_purchase AS (
  SELECT customer_id, MIN(order_purchase_timestamp) AS first_date
  FROM orders
  GROUP BY customer_id
),
repeat_purchase AS (
  SELECT DISTINCT o.customer_id
  FROM orders o
  JOIN first_purchase f
  ON o.customer_id = f.customer_id
  WHERE o.order_purchase_timestamp
        BETWEEN f.first_date
        AND DATE_ADD(f.first_date, INTERVAL 6 MONTH)
        AND o.order_purchase_timestamp > f.first_date
)
SELECT
  COUNT(DISTINCT r.customer_id) * 100.0 /
  COUNT(DISTINCT f.customer_id) AS retention_rate
FROM first_purchase f
LEFT JOIN repeat_purchase r
ON f.customer_id = r.customer_id;

#4.Customer Retention Rate (6 Months)

WITH first_purchase AS (
  SELECT customer_id, MIN(order_purchase_timestamp) AS first_date
  FROM orders
  GROUP BY customer_id
),
repeat_purchase AS (
  SELECT DISTINCT o.customer_id
  FROM orders o
  JOIN first_purchase f
  ON o.customer_id = f.customer_id
  WHERE o.order_purchase_timestamp
        BETWEEN f.first_date
        AND DATE_ADD(f.first_date, INTERVAL 6 MONTH)
        AND o.order_purchase_timestamp > f.first_date
)
SELECT
  COUNT(DISTINCT r.customer_id) * 100.0 /
  COUNT(DISTINCT f.customer_id) AS retention_rate
FROM first_purchase f
LEFT JOIN repeat_purchase r
ON f.customer_id = r.customer_id;

#5. Top 3 Customers per Year by Spend
WITH yearly_spend AS (
  SELECT
    customer_id,
    YEAR(order_purchase_timestamp) AS yr,
    SUM(payment_value) AS spend
  FROM orders o
  JOIN order_payments p
  ON o.order_id = p.order_id
  GROUP BY customer_id, yr
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY yr ORDER BY spend DESC) AS rnk
  FROM yearly_spend
)
SELECT *
FROM ranked
WHERE rnk <= 3;
