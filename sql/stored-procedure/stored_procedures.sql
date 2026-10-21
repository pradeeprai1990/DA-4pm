-- =====================================================================
--  STORED PROCEDURES IN MYSQL - 10 EXAMPLES (for Data Analyst students)
-- =====================================================================
--  What is a Stored Procedure?
--  A saved block of SQL that has a name. You write it once and run it
--  any time with CALL procedure_name();
--
--  Syntax:
--      DELIMITER //
--      CREATE PROCEDURE proc_name(IN p1 INT, OUT p2 INT, INOUT p3 INT)
--      BEGIN
--          -- SQL statements
--      END //
--      DELIMITER ;
--
--  Why DELIMITER?  Statements inside BEGIN...END end with ;
--  so we change the delimiter to // while creating the procedure.
--
--  Parameter types:
--      IN    -> value goes INTO the procedure (default)
--      OUT   -> procedure sends a value OUT to the caller
--      INOUT -> value goes in, gets changed, comes back out
-- =====================================================================


-- =====================================================================
--  STEP 1 : DATASET
-- =====================================================================
DROP DATABASE IF EXISTS shop_db;
CREATE DATABASE shop_db;
USE shop_db;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50),
    city          VARCHAR(30),
    signup_date   DATE
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    category     VARCHAR(30),
    price        DECIMAL(10,2),
    stock        INT
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id  INT,
    quantity    INT,
    order_date  DATE,
    status      VARCHAR(20),          -- Delivered / Pending / Cancelled
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_name   VARCHAR(50),
    department VARCHAR(30),
    salary     DECIMAL(10,2)
);

INSERT INTO customers (customer_name, city, signup_date) VALUES
('Rahul Sharma',  'Delhi',     '2024-01-10'),
('Priya Verma',   'Mumbai',    '2024-02-15'),
('Amit Singh',    'Jaipur',    '2024-03-20'),
('Sneha Gupta',   'Delhi',     '2024-04-05'),
('Vikas Yadav',   'Lucknow',   '2024-05-12'),
('Neha Joshi',    'Mumbai',    '2024-06-18'),
('Rohit Mehta',   'Jaipur',    '2024-07-22'),
('Pooja Patel',   'Ahmedabad', '2024-08-30'),
('Karan Malhotra','Delhi',     '2024-09-14'),
('Anjali Rao',    'Bangalore', '2024-10-01');

INSERT INTO products (product_name, category, price, stock) VALUES
('Laptop',        'Electronics', 55000, 15),
('Smartphone',    'Electronics', 25000, 40),
('Headphones',    'Electronics',  2000,  0),
('Office Chair',  'Furniture',    7000,  8),
('Study Table',   'Furniture',    9000,  3),
('T-Shirt',       'Clothing',      500, 120),
('Jeans',         'Clothing',     1500, 60),
('Water Bottle',  'Accessories',   300, 200);

INSERT INTO orders (customer_id, product_id, quantity, order_date, status) VALUES
(1, 1, 1, '2025-01-05', 'Delivered'),
(2, 2, 2, '2025-01-18', 'Delivered'),
(3, 6, 5, '2025-02-02', 'Delivered'),
(4, 4, 1, '2025-02-20', 'Cancelled'),
(5, 7, 3, '2025-03-11', 'Delivered'),
(1, 8, 4, '2025-03-25', 'Delivered'),
(6, 2, 1, '2025-04-08', 'Pending'),
(7, 5, 1, '2025-04-19', 'Delivered'),
(8, 3, 2, '2025-05-03', 'Delivered'),
(9, 1, 1, '2025-05-27', 'Delivered'),
(2, 6, 10,'2025-06-14', 'Delivered'),
(10,4, 2, '2025-06-29', 'Delivered'),
(3, 2, 1, '2025-07-07', 'Cancelled'),
(4, 7, 2, '2025-07-21', 'Delivered'),
(5, 1, 1, '2025-08-09', 'Delivered'),
(6, 8, 6, '2025-08-30', 'Delivered'),
(1, 2, 1, '2025-09-12', 'Delivered'),
(9, 5, 1, '2025-10-04', 'Pending'),
(7, 6, 8, '2025-11-15', 'Delivered'),
(8, 1, 1, '2025-12-20', 'Delivered');

INSERT INTO employees (emp_name, department, salary) VALUES
('Arjun',  'Sales',     30000),
('Meera',  'Sales',     35000),
('Suresh', 'IT',        60000),
('Kavita', 'IT',        65000),
('Deepak', 'HR',        40000),
('Ritu',   'Marketing', 45000);


-- =====================================================================
--  EXAMPLE 1 : Simple procedure (no parameter)
--  Task : Show all customers
-- =====================================================================
DROP PROCEDURE IF EXISTS get_all_customers;
DELIMITER //
CREATE PROCEDURE get_all_customers()
BEGIN
    SELECT * FROM customers;
END //
DELIMITER ;

CALL get_all_customers();


-- =====================================================================
--  EXAMPLE 2 : IN parameter
--  Task : Show customers of a given city
-- =====================================================================
DROP PROCEDURE IF EXISTS get_customers_by_city;
DELIMITER //
CREATE PROCEDURE get_customers_by_city(IN p_city VARCHAR(30))
BEGIN
    SELECT customer_id, customer_name, city
    FROM customers
    WHERE city = p_city;
END //
DELIMITER ;

CALL get_customers_by_city('Delhi');
CALL get_customers_by_city('Mumbai');


-- =====================================================================
--  EXAMPLE 3 : Multiple IN parameters
--  Task : Orders between two dates with revenue (JOIN inside procedure)
-- =====================================================================
DROP PROCEDURE IF EXISTS get_orders_between;
DELIMITER //
CREATE PROCEDURE get_orders_between(IN p_start DATE, IN p_end DATE)
BEGIN
    SELECT o.order_id, c.customer_name, p.product_name,
           o.quantity, p.price,
           o.quantity * p.price AS revenue,
           o.order_date, o.status
    FROM orders o
    JOIN customers c USING (customer_id)
    JOIN products  p USING (product_id)
    WHERE o.order_date BETWEEN p_start AND p_end
    ORDER BY o.order_date;
END //
DELIMITER ;

CALL get_orders_between('2025-01-01', '2025-03-31');   -- Q1 orders


-- =====================================================================
--  EXAMPLE 4 : OUT parameter
--  Task : Return total revenue (only Delivered orders)
-- =====================================================================
DROP PROCEDURE IF EXISTS get_total_revenue;
DELIMITER //
CREATE PROCEDURE get_total_revenue(OUT p_total DECIMAL(12,2))
BEGIN
    SELECT SUM(o.quantity * p.price) INTO p_total
    FROM orders o
    JOIN products p USING (product_id)
    WHERE o.status = 'Delivered';
END //
DELIMITER ;

CALL get_total_revenue(@total);
SELECT @total AS total_revenue;


-- =====================================================================
--  EXAMPLE 5 : IN + OUT parameters
--  Task : For a category, return number of orders and revenue
-- =====================================================================
DROP PROCEDURE IF EXISTS category_summary;
DELIMITER //
CREATE PROCEDURE category_summary(
    IN  p_category    VARCHAR(30),
    OUT p_total_order INT,
    OUT p_revenue     DECIMAL(12,2)
)
BEGIN
    SELECT COUNT(*), IFNULL(SUM(o.quantity * p.price), 0)
    INTO   p_total_order, p_revenue
    FROM orders o
    JOIN products p USING (product_id)
    WHERE p.category = p_category
      AND o.status = 'Delivered';
END //
DELIMITER ;

CALL category_summary('Electronics', @cnt, @rev);
SELECT @cnt AS total_orders, @rev AS revenue;

CALL category_summary('Clothing', @cnt, @rev);
SELECT @cnt AS total_orders, @rev AS revenue;


-- =====================================================================
--  EXAMPLE 6 : INOUT parameter
--  Task : Apply GST (18%) on an amount - same variable goes in & out
-- =====================================================================
DROP PROCEDURE IF EXISTS add_gst;
DELIMITER //
CREATE PROCEDURE add_gst(INOUT p_amount DECIMAL(12,2))
BEGIN
    SET p_amount = p_amount + (p_amount * 0.18);
END //
DELIMITER ;

SET @price = 1000;
CALL add_gst(@price);
SELECT @price AS price_with_gst;        -- 1180.00


-- =====================================================================
--  EXAMPLE 7 : Variables + IF / ELSEIF / ELSE
--  Task : Give a customer a segment based on total spending
--         >= 50000 -> Gold, >= 10000 -> Silver, else Bronze
-- =====================================================================
DROP PROCEDURE IF EXISTS customer_segment;
DELIMITER //
CREATE PROCEDURE customer_segment(IN p_customer_id INT)
BEGIN
    DECLARE v_spent   DECIMAL(12,2) DEFAULT 0;
    DECLARE v_segment VARCHAR(10);

    SELECT IFNULL(SUM(o.quantity * p.price), 0) INTO v_spent
    FROM orders o
    JOIN products p USING (product_id)
    WHERE o.customer_id = p_customer_id
      AND o.status = 'Delivered';

    IF v_spent >= 50000 THEN
        SET v_segment = 'Gold';
    ELSEIF v_spent >= 10000 THEN
        SET v_segment = 'Silver';
    ELSE
        SET v_segment = 'Bronze';
    END IF;

    SELECT c.customer_name, v_spent AS total_spent, v_segment AS segment
    FROM customers c
    WHERE c.customer_id = p_customer_id;
END //
DELIMITER ;

CALL customer_segment(1);   -- Rahul  -> Gold
CALL customer_segment(3);   -- Amit   -> Bronze
CALL customer_segment(10);  -- Anjali -> Silver


-- =====================================================================
--  EXAMPLE 8 : CASE inside SELECT
--  Task : Stock report of products - Out of Stock / Low / In Stock
-- =====================================================================
DROP PROCEDURE IF EXISTS stock_report;
DELIMITER //
CREATE PROCEDURE stock_report(IN p_low_limit INT)
BEGIN
    SELECT product_name, category, stock,
           CASE
               WHEN stock = 0           THEN 'Out of Stock'
               WHEN stock <= p_low_limit THEN 'Low Stock'
               ELSE 'In Stock'
           END AS stock_status
    FROM products
    ORDER BY stock;
END //
DELIMITER ;

CALL stock_report(10);


-- =====================================================================
--  EXAMPLE 9 : INSERT + UPDATE with validation (SIGNAL = custom error)
--  Task : Place a new order -> check stock -> insert order -> reduce stock
-- =====================================================================
DROP PROCEDURE IF EXISTS place_order;
DELIMITER //
CREATE PROCEDURE place_order(
    IN p_customer_id INT,
    IN p_product_id  INT,
    IN p_quantity    INT
)
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock
    FROM products
    WHERE product_id = p_product_id;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
    ELSEIF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock';
    ELSE
        START TRANSACTION;
            INSERT INTO orders (customer_id, product_id, quantity, order_date, status)
            VALUES (p_customer_id, p_product_id, p_quantity, CURDATE(), 'Pending');

            UPDATE products
            SET stock = stock - p_quantity
            WHERE product_id = p_product_id;
        COMMIT;

        SELECT 'Order placed successfully' AS message;
    END IF;
END //
DELIMITER ;

CALL place_order(2, 7, 2);   -- works : Jeans stock 60 -> 58
CALL place_order(2, 3, 1);   -- error : Headphones stock is 0
SELECT * FROM products WHERE product_id IN (3, 7);


-- =====================================================================
--  EXAMPLE 10 : WHILE loop + temporary table
--  Task : Month-wise revenue report for a year (shows 0 for empty months)
-- =====================================================================
DROP PROCEDURE IF EXISTS monthly_revenue_report;
DELIMITER //
CREATE PROCEDURE monthly_revenue_report(IN p_year INT)
BEGIN
    DECLARE v_month INT DEFAULT 1;

    DROP TEMPORARY TABLE IF EXISTS month_report;
    CREATE TEMPORARY TABLE month_report (
        month_no   INT,
        month_name VARCHAR(15),
        revenue    DECIMAL(12,2)
    );

    WHILE v_month <= 12 DO
        INSERT INTO month_report
        SELECT v_month,
               MONTHNAME(MAKEDATE(p_year, 1) + INTERVAL (v_month - 1) MONTH),
               IFNULL(SUM(o.quantity * p.price), 0)
        FROM orders o
        JOIN products p USING (product_id)
        WHERE YEAR(o.order_date)  = p_year
          AND MONTH(o.order_date) = v_month
          AND o.status = 'Delivered';

        SET v_month = v_month + 1;
    END WHILE;

    SELECT * FROM month_report;
END //
DELIMITER ;

CALL monthly_revenue_report(2025);


-- =====================================================================
--  BONUS : Manage procedures
-- =====================================================================
SHOW PROCEDURE STATUS WHERE Db = 'shop_db';     -- list all procedures
SHOW CREATE PROCEDURE customer_segment;         -- see the code
-- DROP PROCEDURE IF EXISTS get_all_customers;  -- delete a procedure


-- =====================================================================
--  PRACTICE QUESTIONS (try yourself)
-- =====================================================================
-- 1. Create a procedure that takes a department name and shows its
--    employees with salary above the department average.
-- 2. Create a procedure with OUT parameter that returns the count of
--    Cancelled orders.
-- 3. Create a procedure that gives a salary hike (IN percent) to all
--    employees of a given department, then shows the updated rows.
-- 4. Create a procedure that returns the TOP N products by revenue
--    (N is an IN parameter, use LIMIT N).
-- 5. Create a procedure that shows city-wise number of customers and
--    total revenue, sorted by revenue DESC.
