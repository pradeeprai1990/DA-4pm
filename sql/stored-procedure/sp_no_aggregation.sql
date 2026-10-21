-- =====================================================================
--  STORED PROCEDURE - SIMPLE EXAMPLES WITHOUT AGGREGATION
--  (No COUNT / SUM / AVG / MAX / MIN / GROUP BY)
--  Dataset : shop_db  (run stored_procedures.sql first)
--
--  Topics : SELECT, WHERE, ORDER BY, BETWEEN, LIKE, Date filter,
--           LIMIT, JOIN, INSERT, UPDATE
-- =====================================================================
USE shop_db;


-- =====================================================================
--  EXAMPLE 1 : No parameter + ORDER BY
--  QUESTION : Show all products from costliest to cheapest.
-- =====================================================================
DROP PROCEDURE IF EXISTS products_by_price;
DELIMITER //
CREATE PROCEDURE products_by_price()
BEGIN
    SELECT product_name, category, price
    FROM products
    ORDER BY price DESC;
END //
DELIMITER ;

CALL products_by_price();
-- Output : Laptop first ... Water Bottle last

-- YOUR TURN (Q1) : Create employees_by_name() to show all employees
--                  sorted by name (A to Z).


-- =====================================================================
--  EXAMPLE 2 : IN parameter (text) + WHERE
--  QUESTION : Show products of a given category.
-- =====================================================================
DROP PROCEDURE IF EXISTS products_of_category;
DELIMITER //
CREATE PROCEDURE products_of_category(IN p_category VARCHAR(30))
BEGIN
    SELECT product_name, price
    FROM products
    WHERE category = p_category;
END //
DELIMITER ;

CALL products_of_category('Clothing');
-- Output : T-Shirt, Jeans

-- YOUR TURN (Q2) : Create customers_from_city(IN p_city) to show
--                  customers of a given city.  Try 'Jaipur'.


-- =====================================================================
--  EXAMPLE 3 : IN parameter (number) + comparison
--  QUESTION : Show employees earning more than a given salary.
-- =====================================================================
DROP PROCEDURE IF EXISTS employees_salary_above;
DELIMITER //
CREATE PROCEDURE employees_salary_above(IN p_salary INT)
BEGIN
    SELECT emp_name, department, salary
    FROM employees
    WHERE salary > p_salary;
END //
DELIMITER ;

CALL employees_salary_above(40000);
-- Output : Suresh, Kavita, Ritu

-- YOUR TURN (Q3) : Create products_price_above(IN p_price) to show
--                  products costing more than p_price.  Try 20000.


-- =====================================================================
--  EXAMPLE 4 : Two IN parameters + BETWEEN
--  QUESTION : Show products whose price is between two values.
-- =====================================================================
DROP PROCEDURE IF EXISTS products_price_between;
DELIMITER //
CREATE PROCEDURE products_price_between(IN p_min INT, IN p_max INT)
BEGIN
    SELECT product_name, price
    FROM products
    WHERE price BETWEEN p_min AND p_max
    ORDER BY price;
END //
DELIMITER ;

CALL products_price_between(1000, 10000);
-- Output : Jeans, Headphones, Office Chair, Study Table

-- YOUR TURN (Q4) : Create salary_between(IN p_min, IN p_max) to show
--                  employees with salary in that range.
--                  Try (35000, 50000).


-- =====================================================================
--  EXAMPLE 5 : LIKE with parameter
--  QUESTION : Show customers whose name starts with a given letter.
-- =====================================================================
DROP PROCEDURE IF EXISTS customers_name_starts;
DELIMITER //
CREATE PROCEDURE customers_name_starts(IN p_letter VARCHAR(5))
BEGIN
    SELECT customer_name, city
    FROM customers
    WHERE customer_name LIKE CONCAT(p_letter, '%');
END //
DELIMITER ;

CALL customers_name_starts('R');
-- Output : Rahul Sharma, Rohit Mehta

-- YOUR TURN (Q5) : Create search_product(IN p_word) to show products
--                  whose name CONTAINS the given word.  Try 'Table'.
--                  Hint : CONCAT('%', p_word, '%')


-- =====================================================================
--  EXAMPLE 6 : DATE parameter
--  QUESTION : Show customers who signed up after a given date.
-- =====================================================================
DROP PROCEDURE IF EXISTS customers_joined_after;
DELIMITER //
CREATE PROCEDURE customers_joined_after(IN p_date DATE)
BEGIN
    SELECT customer_name, signup_date
    FROM customers
    WHERE signup_date > p_date
    ORDER BY signup_date;
END //
DELIMITER ;

CALL customers_joined_after('2024-06-01');
-- Output : Neha, Rohit, Pooja, Karan, Anjali

-- YOUR TURN (Q6) : Create orders_in_month(IN p_month INT) to show orders
--                  of a given month of 2025.  Try 3 (March).
--                  Hint : MONTH(order_date)


-- =====================================================================
--  EXAMPLE 7 : LIMIT with parameter (Top N)
--  QUESTION : Show the top N costliest products.
-- =====================================================================
DROP PROCEDURE IF EXISTS top_costly_products;
DELIMITER //
CREATE PROCEDURE top_costly_products(IN p_n INT)
BEGIN
    SELECT product_name, price
    FROM products
    ORDER BY price DESC
    LIMIT p_n;
END //
DELIMITER ;

CALL top_costly_products(3);
-- Output : Laptop, Smartphone, Study Table

-- YOUR TURN (Q7) : Create top_paid_employees(IN p_n) to show the top N
--                  highest paid employees.  Try 2.


-- =====================================================================
--  EXAMPLE 8 : JOIN inside procedure
--  QUESTION : Show order details (customer name, product name) for a
--             given order status.
-- =====================================================================
DROP PROCEDURE IF EXISTS order_details_by_status;
DELIMITER //
CREATE PROCEDURE order_details_by_status(IN p_status VARCHAR(20))
BEGIN
    SELECT o.order_id, c.customer_name, p.product_name,
           o.quantity, o.order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products  p ON o.product_id  = p.product_id
    WHERE o.status = p_status;
END //
DELIMITER ;

CALL order_details_by_status('Cancelled');
-- Output : order 4 (Sneha Gupta, Office Chair), order 13 (Amit Singh, Smartphone)

-- YOUR TURN (Q8) : Create orders_of_city(IN p_city) to show order_id,
--                  customer_name and order_date for customers of a city.
--                  Try 'Mumbai'.


-- =====================================================================
--  EXAMPLE 9 : INSERT with parameters
--  QUESTION : Add a new customer.
-- =====================================================================
DROP PROCEDURE IF EXISTS add_customer;
DELIMITER //
CREATE PROCEDURE add_customer(IN p_name VARCHAR(50), IN p_city VARCHAR(30))
BEGIN
    INSERT INTO customers (customer_name, city, signup_date)
    VALUES (p_name, p_city, CURDATE());

    SELECT * FROM customers WHERE customer_name = p_name;
END //
DELIMITER ;

CALL add_customer('Manish Kumar', 'Indore');
-- Output : new row for Manish Kumar with today's date

-- YOUR TURN (Q9) : Create add_employee(IN p_name, IN p_dept, IN p_salary)
--                  to insert a new employee.


-- =====================================================================
--  EXAMPLE 10 : UPDATE with parameters
--  QUESTION : Change the price of a product.
-- =====================================================================
DROP PROCEDURE IF EXISTS change_price;
DELIMITER //
CREATE PROCEDURE change_price(IN p_product_id INT, IN p_new_price DECIMAL(10,2))
BEGIN
    UPDATE products
    SET price = p_new_price
    WHERE product_id = p_product_id;

    SELECT product_name, price FROM products WHERE product_id = p_product_id;
END //
DELIMITER ;

CALL change_price(8, 350);
-- Output : Water Bottle 350.00

-- YOUR TURN (Q10) : Create change_department(IN p_emp_id, IN p_dept) to
--                   move an employee to another department.


-- =====================================================================
--  SOLUTIONS (Teacher copy - remove before sharing with students)
-- =====================================================================

-- Q1
DROP PROCEDURE IF EXISTS employees_by_name;
DELIMITER //
CREATE PROCEDURE employees_by_name()
BEGIN
    SELECT * FROM employees ORDER BY emp_name;
END //
DELIMITER ;
CALL employees_by_name();

-- Q2
DROP PROCEDURE IF EXISTS customers_from_city;
DELIMITER //
CREATE PROCEDURE customers_from_city(IN p_city VARCHAR(30))
BEGIN
    SELECT customer_name, city FROM customers WHERE city = p_city;
END //
DELIMITER ;
CALL customers_from_city('Jaipur');            -- Amit Singh, Rohit Mehta

-- Q3
DROP PROCEDURE IF EXISTS products_price_above;
DELIMITER //
CREATE PROCEDURE products_price_above(IN p_price INT)
BEGIN
    SELECT product_name, price FROM products WHERE price > p_price;
END //
DELIMITER ;
CALL products_price_above(20000);              -- Laptop, Smartphone

-- Q4
DROP PROCEDURE IF EXISTS salary_between;
DELIMITER //
CREATE PROCEDURE salary_between(IN p_min INT, IN p_max INT)
BEGIN
    SELECT emp_name, salary FROM employees
    WHERE salary BETWEEN p_min AND p_max;
END //
DELIMITER ;
CALL salary_between(35000, 50000);             -- Meera, Deepak, Ritu

-- Q5
DROP PROCEDURE IF EXISTS search_product;
DELIMITER //
CREATE PROCEDURE search_product(IN p_word VARCHAR(30))
BEGIN
    SELECT product_name, price FROM products
    WHERE product_name LIKE CONCAT('%', p_word, '%');
END //
DELIMITER ;
CALL search_product('Table');                  -- Study Table

-- Q6
DROP PROCEDURE IF EXISTS orders_in_month;
DELIMITER //
CREATE PROCEDURE orders_in_month(IN p_month INT)
BEGIN
    SELECT * FROM orders
    WHERE YEAR(order_date) = 2025 AND MONTH(order_date) = p_month;
END //
DELIMITER ;
CALL orders_in_month(3);                       -- orders 5, 6

-- Q7
DROP PROCEDURE IF EXISTS top_paid_employees;
DELIMITER //
CREATE PROCEDURE top_paid_employees(IN p_n INT)
BEGIN
    SELECT emp_name, salary FROM employees
    ORDER BY salary DESC
    LIMIT p_n;
END //
DELIMITER ;
CALL top_paid_employees(2);                    -- Kavita, Suresh

-- Q8
DROP PROCEDURE IF EXISTS orders_of_city;
DELIMITER //
CREATE PROCEDURE orders_of_city(IN p_city VARCHAR(30))
BEGIN
    SELECT o.order_id, c.customer_name, o.order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.city = p_city;
END //
DELIMITER ;
CALL orders_of_city('Mumbai');                 -- Priya & Neha's orders

-- Q9
DROP PROCEDURE IF EXISTS add_employee;
DELIMITER //
CREATE PROCEDURE add_employee(IN p_name VARCHAR(50), IN p_dept VARCHAR(30), IN p_salary DECIMAL(10,2))
BEGIN
    INSERT INTO employees (emp_name, department, salary)
    VALUES (p_name, p_dept, p_salary);

    SELECT * FROM employees WHERE emp_name = p_name;
END //
DELIMITER ;
CALL add_employee('Sanjay', 'Finance', 50000);

-- Q10
DROP PROCEDURE IF EXISTS change_department;
DELIMITER //
CREATE PROCEDURE change_department(IN p_emp_id INT, IN p_dept VARCHAR(30))
BEGIN
    UPDATE employees SET department = p_dept WHERE emp_id = p_emp_id;

    SELECT * FROM employees WHERE emp_id = p_emp_id;
END //
DELIMITER ;
CALL change_department(1, 'Marketing');        -- Arjun -> Marketing
