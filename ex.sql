 =====================================================================
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
