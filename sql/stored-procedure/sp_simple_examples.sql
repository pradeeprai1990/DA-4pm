-- =====================================================================
--  STORED PROCEDURE - SIMPLE EXAMPLES + YOUR TURN QUESTIONS
--  Dataset : shop_db  (run stored_procedures.sql first)
--
--  How to use this file:
--    1. Read the QUESTION
--    2. Run the EXAMPLE and check the output
--    3. Solve the YOUR TURN question yourself (same pattern)
-- =====================================================================
USE shop_db;


-- =====================================================================
--  EXAMPLE 1 : Procedure without parameter
--  QUESTION : Show name and city of all customers.
-- =====================================================================
DROP PROCEDURE IF EXISTS show_customers;
DELIMITER //
CREATE PROCEDURE show_customers()
BEGIN
    SELECT customer_name, city FROM customers;
END //
DELIMITER ;

CALL show_customers();
-- Output : 10 rows (all customers)

-- YOUR TURN : Create show_all_employees() to show all employees.


-- =====================================================================
--  EXAMPLE 2 : IN parameter (text)
--  QUESTION : Show customers who live in a given city.
-- =====================================================================
DROP PROCEDURE IF EXISTS customers_in_city;
DELIMITER //
CREATE PROCEDURE customers_in_city(IN p_city VARCHAR(30))
BEGIN
    SELECT customer_name, city
    FROM customers
    WHERE city = p_city;
END //
DELIMITER ;

CALL customers_in_city('Delhi');
-- Output : Rahul Sharma, Sneha Gupta, Karan Malhotra

-- YOUR TURN : Create employees_in_dept(IN p_dept) to show employees
--             of a given department.  Try : CALL employees_in_dept('IT');


-- =====================================================================
--  EXAMPLE 3 : IN parameter (number)
--  QUESTION : Show products cheaper than a given price.
-- =====================================================================
DROP PROCEDURE IF EXISTS products_below_price;
DELIMITER //
CREATE PROCEDURE products_below_price(IN p_price INT)
BEGIN
    SELECT product_name, price
    FROM products
    WHERE price < p_price;
END //
DELIMITER ;

CALL products_below_price(1000);
-- Output : T-Shirt 500, Water Bottle 300

-- YOUR TURN : Create salary_above(IN p_salary) to show employees
--             earning more than the given salary.


-- =====================================================================
--  EXAMPLE 4 : IN parameter (id)
--  QUESTION : Show all orders of a given customer.
-- =====================================================================
DROP PROCEDURE IF EXISTS orders_of_customer;
DELIMITER //
CREATE PROCEDURE orders_of_customer(IN p_customer_id INT)
BEGIN
    SELECT order_id, product_id, quantity, order_date, status
    FROM orders
    WHERE customer_id = p_customer_id;
END //
DELIMITER ;

CALL orders_of_customer(1);
-- Output : order_id 1, 6, 17

-- YOUR TURN : Create orders_of_product(IN p_product_id) to show all
--             orders of a given product.


-- =====================================================================
--  EXAMPLE 5 : Two IN parameters
--  QUESTION : Show products of a given category under a given price.
-- =====================================================================
DROP PROCEDURE IF EXISTS category_under_price;
DELIMITER //
CREATE PROCEDURE category_under_price(IN p_category VARCHAR(30), IN p_price INT)
BEGIN
    SELECT product_name, category, price
    FROM products
    WHERE category = p_category
      AND price < p_price;
END //
DELIMITER ;

CALL category_under_price('Electronics', 30000);
-- Output : Smartphone 25000, Headphones 2000

-- YOUR TURN : Create dept_salary_above(IN p_dept, IN p_salary) to show
--             employees of a department earning more than p_salary.


-- =====================================================================
--  EXAMPLE 6 : OUT parameter (COUNT)
--  QUESTION : Return the total number of products.
-- =====================================================================
DROP PROCEDURE IF EXISTS total_products;
DELIMITER //
CREATE PROCEDURE total_products(OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM products;
END //
DELIMITER ;

CALL total_products(@total);
SELECT @total AS total_products;
-- Output : 8

-- YOUR TURN : Create total_employees(OUT p_total) to return the
--             number of employees.  (Answer : 6)


-- =====================================================================
--  EXAMPLE 7 : OUT parameter (MAX)
--  QUESTION : Return the highest product price.
-- =====================================================================
DROP PROCEDURE IF EXISTS highest_price;
DELIMITER //
CREATE PROCEDURE highest_price(OUT p_max DECIMAL(10,2))
BEGIN
    SELECT MAX(price) INTO p_max FROM products;
END //
DELIMITER ;

CALL highest_price(@max_price);
SELECT @max_price AS highest_price;
-- Output : 55000.00

-- YOUR TURN : Create lowest_salary(OUT p_min) to return the minimum
--             employee salary.  (Answer : 30000.00)


-- =====================================================================
--  EXAMPLE 8 : IN + OUT parameter
--  QUESTION : Return how many customers live in a given city.
-- =====================================================================
DROP PROCEDURE IF EXISTS count_city_customers;
DELIMITER //
CREATE PROCEDURE count_city_customers(IN p_city VARCHAR(30), OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM customers
    WHERE city = p_city;
END //
DELIMITER ;

CALL count_city_customers('Delhi', @cnt);
SELECT @cnt AS delhi_customers;
-- Output : 3

-- YOUR TURN : Create count_orders_by_status(IN p_status, OUT p_count)
--             Try 'Cancelled'.  (Answer : 2)


-- =====================================================================
--  EXAMPLE 9 : GROUP BY inside procedure
--  QUESTION : Show number of customers in each city.
-- =====================================================================
DROP PROCEDURE IF EXISTS city_wise_customers;
DELIMITER //
CREATE PROCEDURE city_wise_customers()
BEGIN
    SELECT city, COUNT(*) AS total_customers
    FROM customers
    GROUP BY city
    ORDER BY total_customers DESC;
END //
DELIMITER ;

CALL city_wise_customers();
-- Output : Delhi 3, Mumbai 2, Jaipur 2, Lucknow 1, Ahmedabad 1, Bangalore 1

-- YOUR TURN : Create dept_wise_employees() to show number of employees
--             and total salary in each department.


-- =====================================================================
--  EXAMPLE 10 : DECLARE variable + IF / ELSE
--  QUESTION : For a product_id, show 'Expensive' if price > 10000,
--             otherwise 'Affordable'.
-- =====================================================================
DROP PROCEDURE IF EXISTS price_tag;
DELIMITER //
CREATE PROCEDURE price_tag(IN p_product_id INT)
BEGIN
    DECLARE v_price DECIMAL(10,2);

    SELECT price INTO v_price
    FROM products
    WHERE product_id = p_product_id;

    IF v_price > 10000 THEN
        SELECT 'Expensive' AS result;
    ELSE
        SELECT 'Affordable' AS result;
    END IF;
END //
DELIMITER ;

CALL price_tag(1);      -- Laptop  -> Expensive
CALL price_tag(6);      -- T-Shirt -> Affordable

-- YOUR TURN : Create employee_level(IN p_emp_id) to show 'Senior' if
--             salary > 50000, otherwise 'Junior'.
--             Try : CALL employee_level(3);  (Answer : Senior)
