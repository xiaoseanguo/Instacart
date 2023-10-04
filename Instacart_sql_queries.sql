## Create database
CREATE DATABASE instacart_mini;
USE instacart_mini;

## Build table structures##
# Create products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
product_id INT,
product_name VARCHAR(255),
aisle_id INT,
department_id INT);

# Create aisles table
DROP TABLE IF EXISTS aisles;
CREATE TABLE aisles (
aisle_id INT,
aisle VARCHAR(255));

# Create departments table
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
department_id INT,
department VARCHAR(255));

# Create orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
order_id INT,
user_id INT,
eval_set VARCHAR(255),
order_number INT,
order_dow INT,
order_hour_of_day INT,
days_since_prior_order INT);

# Create order products prior table
DROP TABLE IF EXISTS order_products__prior;
CREATE TABLE order_products__prior (
order_id INT,
product_id INT,
add_to_cart_order INT,
reordered TINYINT);

# Create order products train table
DROP TABLE IF EXISTS order_products__train;
CREATE TABLE order_products__train (
order_id INT,
product_id INT,
add_to_cart_order INT,
reordered TINYINT);


## Import csv files##
# Import products table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\products_clean.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Import aisles table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\aisles.csv'
INTO TABLE aisles
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Import departments table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\departments.csv'
INTO TABLE departments
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Import orders table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Import order_products__prior table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\order_products_prior.csv'
INTO TABLE order_products__prior
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Import order_products__train table
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\instacart_data\\order_products_train.csv'
INTO TABLE order_products__train
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


## Preprocessing ##
# Check for null values
SELECT *
FROM products
WHERE product_id  IS NULL OR product_name IS NULL OR aisle_id IS NULL OR department_id IS NULL;
SELECT *
FROM aisles 
WHERE aisle_id IS NULL OR aisle IS NULL;
SELECT *
FROM departments 
WHERE department_id IS NULL OR department IS NULL;
SELECT *
FROM orders 
WHERE order_id IS NULL OR user_id IS NULL OR eval_set IS NULL OR order_number IS NULL OR order_dow IS NULL OR order_hour_of_day IS NULL OR days_since_prior_order IS NULL;
SELECT *
FROM order_products__prior 
WHERE order_id IS NULL OR product_id IS NULL OR add_to_cart_order IS NULL OR reordered IS NULL;
SELECT *
FROM order_products__train 
WHERE order_id IS NULL OR product_id IS NULL OR add_to_cart_order IS NULL OR reordered IS NULL;

# Check for duplicate rows
SELECT *, COUNT(*)
FROM products
GROUP BY product_id, product_name, aisle_id, department_id IS NULL
HAVING COUNT(*) > 1;
SELECT *, COUNT(*)
FROM aisles
GROUP BY aisle_id, aisle
HAVING COUNT(*) > 1;
SELECT *, COUNT(*)
FROM departments
GROUP BY department_id, department
HAVING COUNT(*) > 1;
SELECT *, COUNT(*)
FROM orders
GROUP BY order_id, user_id, eval_set, order_number, order_dow, order_hour_of_day, days_since_prior_order
HAVING COUNT(*) > 1;
SELECT *, COUNT(*)
FROM order_products__prior
GROUP BY order_id, product_id, add_to_cart_order, reordered
HAVING COUNT(*) > 1;
SELECT *, COUNT(*)
FROM order_products__train
GROUP BY order_id, product_id, add_to_cart_order, reordered
HAVING COUNT(*) > 1;

# Combine order_products__prior & order_products__train tables
DROP VIEW IF EXISTS order_products;
CREATE VIEW order_products AS
SELECT *
FROM order_products__prior
UNION
SELECT *
FROM order_products__train;

# Filter orders table for only available data
DROP VIEW IF EXISTS known_orders;
CREATE VIEW known_orders AS
SELECT *
FROM orders
WHERE eval_set IN ('prior', 'train');

# Merge product table with aisle and department names
DROP VIEW IF EXISTS named_products;
CREATE VIEW	 named_products AS
SELECT p.product_id, p.product_name, p.aisle_id, p.department_id, a.aisle, d.department
FROM products p 
LEFT JOIN aisles a ON p.aisle_id = a.aisle_id
LEFT JOIN departments d ON p.department_id = d.department_id;

# Create full table 
DROP VIEW IF EXISTS complete_table;
CREATE VIEW complete_table AS 
SELECT o.order_id, o.product_id, o.reordered, k.user_id, k.order_dow, k.order_hour_of_day, k.days_since_prior_order, n.product_name, n.aisle_id, n.department_id, n.aisle, n.department 
FROM order_products o 
LEFT JOIN known_orders k ON o.order_id = k.order_id
LEFT JOIN named_products n ON o.product_id = n.product_id;

# Check for null values
SELECT *
FROM complete_table
WHERE order_id  IS NULL OR product_id IS NULL OR reordered IS NULL OR user_id IS NULL OR order_dow IS NULL OR order_hour_of_day IS NULL OR days_since_prior_order IS NULL OR product_name IS NULL OR aisle_id IS NULL OR department_id IS NULL OR aisle IS NULL OR department IS NULL;


## Query database to generate calculated tables
# Create date time analysis table
SELECT order_dow, order_hour_of_day, COUNT(DISTINCT order_id) AS order_count
FROM complete_table
GROUP BY order_dow, order_hour_of_day
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\order_date_time.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

# Create basket size table
SELECT order_id, user_id, COUNT(product_id) AS item_count_per_order
FROM complete_table
GROUP BY order_id
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\orders_df_concise_new_col.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


# Calculate total times each product has been ordered
CREATE TEMPORARY TABLE prod_count_transaction
SELECT product_id, COUNT(order_id) AS transaction_count_per_product
FROM complete_table
GROUP BY product_id;

# Calculate total times each product has been reordered
CREATE TEMPORARY TABLE prod_count_reorder
SELECT product_id, COUNT(order_id) AS reorder_count_per_product
FROM complete_table
WHERE reordered = 1
GROUP BY product_id;

# Calculate number of users that bought each product 
CREATE TEMPORARY TABLE prod_count_user
SELECT product_id, COUNT(DISTINCT user_id) AS user_count_per_product
FROM complete_table
GROUP BY product_id;


# Calculate total units of product each user ordered
CREATE TEMPORARY TABLE user_count_order
SELECT user_id, COUNT(order_id) AS order_count_per_user
FROM complete_table
GROUP BY user_id;

# Calculate total units of product each user reordered
CREATE TEMPORARY TABLE user_count_reorder
SELECT user_id, COUNT(order_id) AS reorder_count_per_user
FROM complete_table
WHERE reordered = 1
GROUP BY user_id;

# Calculate number of trips per customer
CREATE TEMPORARY TABLE user_count_trip
SELECT user_id, COUNT(DISTINCT order_id) AS trip_count_per_user
FROM complete_table
GROUP BY user_id;

# Calculate number of product varieties each user bought
CREATE TEMPORARY TABLE user_count_prod
SELECT user_id, COUNT(DISTINCT product_id) AS product_variety_per_user
FROM complete_table
GROUP BY user_id;

# Calculate average basket size of each user 
CREATE TEMPORARY TABLE user_avg_basket
SELECT a.user_id, AVG(a.basket_size) AS basket_avg_per_user
FROM (SELECT c.user_id, b.basket_size
	FROM (SELECT DISTINCT order_id, user_id
		FROM complete_table) c
	LEFT JOIN (SELECT order_id, COUNT(product_id) AS basket_size
		FROM complete_table
		GROUP BY order_id) b
	ON c.order_id = b.order_id) a
GROUP BY a.user_id;

# Calculate average number of days user reorder
CREATE TEMPORARY TABLE user_avg_day_interval
SELECT a.user_id, AVG(a. days_since_prior_order_compiled) AS reorder_avg_days_per_user
FROM (SELECT order_id, user_id, reordered, AVG(days_since_prior_order) AS days_since_prior_order_compiled
	FROM complete_table
    GROUP BY order_id) a
WHERE a.reordered = 1
GROUP BY a.user_id;


# Create product analysis table 
SELECT *
FROM named_products p
LEFT JOIN prod_count_transaction t ON p.product_id = t.product_id
LEFT JOIN prod_count_reorder r ON p.product_id = r.product_id
LEFT JOIN prod_count_user u ON p.product_id = u.product_id
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products_df_new_col.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

# Create user analysis table 
SELECT * 
FROM (SELECT DISTINCT user_id
	FROM known_orders) u
LEFT JOIN user_count_order o ON u.user_id = o.user_id
LEFT JOIN user_count_reorder r ON u.user_id = r.user_id
LEFT JOIN user_count_trip t ON u.user_id = t.user_id
LEFT JOIN user_count_prod p ON u.user_id = p.user_id
LEFT JOIN user_avg_basket b ON u.user_id = b.user_id
LEFT JOIN user_avg_day_interval i ON u.user_id = i.user_id
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_df_new_col.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

