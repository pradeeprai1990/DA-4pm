-- =====================================================================
-- DAY 1 : MORE PRACTICE QUESTIONS WITH ANSWERS  (tables: products, employees)
-- Use only OVER() today (no PARTITION BY yet).
-- Run the dataset below first, try each question yourself,
-- then check the answer written just below it.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS window_fn_course;
USE window_fn_course;

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(30),
    category      VARCHAR(20),
    price         INT,
    units_sold    INT
);

INSERT INTO products (product_id, product_name, category, price, units_sold) VALUES
(1,  'Laptop',     'Electronics', 55000,  12),
(2,  'Mobile',     'Electronics', 20000,  30),
(3,  'Headphones', 'Electronics',  2000,  50),
(4,  'Chair',      'Furniture',    4000,  20),
(5,  'Table',      'Furniture',    8000,  10),
(6,  'Sofa',       'Furniture',   30000,   4),
(7,  'T-Shirt',    'Clothing',      500, 100),
(8,  'Jeans',      'Clothing',     1500,  60),
(9,  'Jacket',     'Clothing',     3000,  25),
(10, 'Watch',      'Accessories',  5000,  18);

SELECT * FROM products;


-- ---------------------------------------------------------------------
-- LEVEL 1 : BASIC  (one window function)
-- ---------------------------------------------------------------------

-- Q1. Show every product's name, price and the total number of products
--     on every row.
-- ANSWER:
SELECT product_name, price,
       COUNT(*) OVER () AS total_products          -- 10
FROM products;


-- Q2. Show every product with the average price of all products.
-- ANSWER:
SELECT product_name, price,
       AVG(price) OVER () AS avg_price             -- 12900
FROM products;


-- Q3. Show every product with the cheapest and the costliest price
--     in the store.
-- ANSWER:
SELECT product_name, price,
       MIN(price) OVER () AS cheapest_price,       -- 500
       MAX(price) OVER () AS costliest_price       -- 55000
FROM products;


-- Q4. Show every product with the total units sold by the whole store.
-- ANSWER:
SELECT product_name, units_sold,
       SUM(units_sold) OVER () AS total_units      -- 329
FROM products;


-- Q5. Show every product with the price range of the store
--     (costliest price - cheapest price).
-- ANSWER:
SELECT product_name, price,
       MAX(price) OVER () - MIN(price) OVER () AS price_range   -- 54500
FROM products;


-- ---------------------------------------------------------------------
-- LEVEL 2 : CALCULATIONS WITH THE WINDOW RESULT
-- ---------------------------------------------------------------------

-- Q6. Calculate revenue (price * units_sold) for each product and show
--     the total revenue of the whole store on every row.
-- ANSWER:
SELECT product_name, price, units_sold,
       price * units_sold              AS revenue,
       SUM(price * units_sold) OVER () AS total_revenue         -- 1945000
FROM products;


-- Q7. Show each product's revenue as a % of total store revenue
--     (2 decimals).
-- ANSWER:
SELECT product_name,
       price * units_sold AS revenue,
       ROUND(price * units_sold * 100.0 / SUM(price * units_sold) OVER (), 2) AS pct_of_revenue
FROM products;


-- Q8. Show how many units each product sold above or below the
--     average units sold (1 decimal).
-- ANSWER:
SELECT product_name, units_sold,
       ROUND(AVG(units_sold) OVER (), 1)              AS avg_units,       -- 32.9
       ROUND(units_sold - AVG(units_sold) OVER (), 1) AS diff_from_avg
FROM products;


-- Q9. Show each product's price as a % of the costliest product's price.
-- ANSWER:
SELECT product_name, price,
       ROUND(price * 100.0 / MAX(price) OVER (), 2) AS pct_of_costliest
FROM products;


-- Q10. Add a column 'Premium' if price is above the average price,
--      otherwise 'Budget'.
-- ANSWER:
SELECT product_name, price,
       CASE
           WHEN price > AVG(price) OVER () THEN 'Premium'
           ELSE 'Budget'
       END AS price_segment
FROM products;


-- ---------------------------------------------------------------------
-- LEVEL 3 : WINDOW + WHERE / SUBQUERY
-- ---------------------------------------------------------------------

-- Q11. Only for 'Clothing' products: show name, units_sold and the total
--      units sold of Clothing on every row.
-- ANSWER:  (WHERE runs first, so the window only sees Clothing rows)
SELECT product_name, category, units_sold,
       SUM(units_sold) OVER () AS clothing_units   -- 185
FROM products
WHERE category = 'Clothing';


-- Q12. List only the products whose price is ABOVE the average price.
--      Hint: a window function cannot be used inside WHERE.
--            Calculate it in a subquery first, then filter outside.
-- ANSWER:
SELECT product_name, price, avg_price
FROM (
    SELECT product_name, price,
           AVG(price) OVER () AS avg_price
    FROM products
) AS t
WHERE price > avg_price;
-- Result: Laptop, Mobile, Sofa


-- Q13. List only the products that contribute MORE than 10% of the
--      total store revenue.
-- ANSWER:
SELECT product_name, revenue, pct_of_revenue
FROM (
    SELECT product_name,
           price * units_sold AS revenue,
           ROUND(price * units_sold * 100.0 / SUM(price * units_sold) OVER (), 2) AS pct_of_revenue
    FROM products
) AS t
WHERE pct_of_revenue > 10;
-- Result: Laptop (33.93%), Mobile (30.85%)


-- Q14. Show every product and, on every row, how many products cost
--      more than 5000.
--      Hint: SUM(CASE WHEN ... THEN 1 ELSE 0 END) OVER ()
-- ANSWER:
SELECT product_name, price,
       SUM(CASE WHEN price > 5000 THEN 1 ELSE 0 END) OVER () AS products_above_5000   -- 4
FROM products;


-- ---------------------------------------------------------------------
-- LEVEL 4 : EMPLOYEES TABLE  (run 01_dataset.sql first)
-- ---------------------------------------------------------------------

-- Q15. If every employee gets a 10% raise, show each employee's new
--      salary and the NEW total company salary on every row.
-- ANSWER:
SELECT emp_name, salary,
       ROUND(salary * 1.10, 0)              AS new_salary,
       ROUND(SUM(salary * 1.10) OVER (), 0) AS new_company_total   -- 980100
FROM employees;


-- Q16. Show only the employees who earn more than the company average,
--      along with the company average.
-- ANSWER:
SELECT emp_name, salary, company_avg
FROM (
    SELECT emp_name, salary,
           ROUND(AVG(salary) OVER (), 0) AS company_avg            -- 59400
    FROM employees
) AS t
WHERE salary > company_avg;
-- Result: 7 employees (Kabir, Ananya, Vivaan, Isha, Priya, Rahul, Neel)


-- Q17. Show each employee's salary, the company average, and a label:
--      'Top Earner'  -> salary is the highest in the company
--      'Above Avg'   -> salary above the average
--      'Below Avg'   -> everyone else
-- ANSWER:  (check the highest first, otherwise the top earner gets 'Above Avg')
SELECT emp_name, salary,
       ROUND(AVG(salary) OVER (), 0) AS company_avg,
       CASE
           WHEN salary = MAX(salary) OVER () THEN 'Top Earner'
           WHEN salary > AVG(salary) OVER () THEN 'Above Avg'
           ELSE 'Below Avg'
       END AS salary_label
FROM employees;


-- Q18. FIND THE ERROR: the query below fails. Why? Fix it.
--      SELECT emp_name, salary
--      FROM employees
--      WHERE salary > AVG(salary) OVER ();
-- ANSWER:
-- Window functions are calculated AFTER the WHERE clause runs,
-- so they cannot be used inside WHERE.
-- Order: FROM -> WHERE -> GROUP BY -> HAVING -> window -> SELECT -> ORDER BY
-- Fix: calculate the window in a subquery and filter outside.
SELECT emp_name, salary
FROM (
    SELECT emp_name, salary,
           AVG(salary) OVER () AS company_avg
    FROM employees
) AS t
WHERE salary > company_avg;
