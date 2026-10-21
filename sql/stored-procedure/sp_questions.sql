-- =====================================================================
--  STORED PROCEDURE - SIMPLE QUESTIONS  (Dataset : shop_db)
--  Run stored_procedures.sql first to create the dataset.
-- =====================================================================
USE shop_db;

-- ---------------------------------------------------------------------
--  QUESTIONS
-- ---------------------------------------------------------------------
-- Q1.  Create a procedure that shows all products.
-- Q2.  Create a procedure that shows all employees, highest salary first.
-- Q3.  Create a procedure that takes a category and shows its products.
-- Q4.  Create a procedure that takes an order status and shows those orders.
-- Q5.  Create a procedure that takes a price and shows products costing
--      more than that price.
-- Q6.  Create a procedure that returns (OUT) the total number of customers.
-- Q7.  Create a procedure that takes a department and returns (OUT) the
--      average salary of that department.
-- Q8.  Create a procedure that takes a product_id and shows
--      'Available' if stock > 0, otherwise 'Not Available'.
-- Q9.  Create a procedure that shows each employee's salary grade using CASE:
--      salary >= 60000 -> 'High', >= 40000 -> 'Medium', else 'Low'.
-- Q10. Create a procedure that takes a product_id and a quantity and
--      adds that quantity to the product's stock.


-- ---------------------------------------------------------------------
--  SOLUTIONS
-- ---------------------------------------------------------------------

-- Q1
DROP PROCEDURE IF EXISTS show_products;
DELIMITER //
CREATE PROCEDURE show_products()
BEGIN
    SELECT * FROM products;
END //
DELIMITER ;

CALL show_products();


-- Q2
DROP PROCEDURE IF EXISTS show_employees;
DELIMITER //
CREATE PROCEDURE show_employees()
BEGIN
    SELECT * FROM employees
    ORDER BY salary DESC;
END //
DELIMITER ;

CALL show_employees();


-- Q3
DROP PROCEDURE IF EXISTS products_by_category;
DELIMITER //
CREATE PROCEDURE products_by_category(IN p_category VARCHAR(30))
BEGIN
    SELECT * FROM products
    WHERE category = p_category;
END //
DELIMITER ;

CALL products_by_category('Furniture');


-- Q4
DROP PROCEDURE IF EXISTS orders_by_status;
DELIMITER //
CREATE PROCEDURE orders_by_status(IN p_status VARCHAR(20))
BEGIN
    SELECT * FROM orders
    WHERE status = p_status;
END //
DELIMITER ;

CALL orders_by_status('Pending');


-- Q5
DROP PROCEDURE IF EXISTS products_above_price;
DELIMITER //
CREATE PROCEDURE products_above_price(IN p_price DECIMAL(10,2))
BEGIN
    SELECT product_name, price
    FROM products
    WHERE price > p_price
    ORDER BY price;
END //
DELIMITER ;

CALL products_above_price(5000);


-- Q6
DROP PROCEDURE IF EXISTS count_customers;
DELIMITER //
CREATE PROCEDURE count_customers(OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count FROM customers;
END //
DELIMITER ;

CALL count_customers(@total_customers);
SELECT @total_customers AS total_customers;     -- 10


-- Q7
DROP PROCEDURE IF EXISTS dept_avg_salary;
DELIMITER //
CREATE PROCEDURE dept_avg_salary(IN p_dept VARCHAR(30), OUT p_avg DECIMAL(10,2))
BEGIN
    SELECT AVG(salary) INTO p_avg
    FROM employees
    WHERE department = p_dept;
END //
DELIMITER ;

CALL dept_avg_salary('IT', @avg_sal);
SELECT @avg_sal AS it_avg_salary;               -- 62500.00


-- Q8
DROP PROCEDURE IF EXISTS check_availability;
DELIMITER //
CREATE PROCEDURE check_availability(IN p_product_id INT)
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock
    FROM products
    WHERE product_id = p_product_id;

    IF v_stock > 0 THEN
        SELECT 'Available' AS result;
    ELSE
        SELECT 'Not Available' AS result;
    END IF;
END //
DELIMITER ;

CALL check_availability(1);     -- Laptop     -> Available
CALL check_availability(3);     -- Headphones -> Not Available


-- Q9
DROP PROCEDURE IF EXISTS salary_grade;
DELIMITER //
CREATE PROCEDURE salary_grade()
BEGIN
    SELECT emp_name, department, salary,
           CASE
               WHEN salary >= 60000 THEN 'High'
               WHEN salary >= 40000 THEN 'Medium'
               ELSE 'Low'
           END AS grade
    FROM employees;
END //
DELIMITER ;

CALL salary_grade();


-- Q10
DROP PROCEDURE IF EXISTS add_stock;
DELIMITER //
CREATE PROCEDURE add_stock(IN p_product_id INT, IN p_qty INT)
BEGIN
    UPDATE products
    SET stock = stock + p_qty
    WHERE product_id = p_product_id;

    SELECT * FROM products WHERE product_id = p_product_id;
END //
DELIMITER ;

CALL add_stock(3, 25);          -- Headphones stock 0 -> 25
