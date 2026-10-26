-- =====================================================================
-- DAY 1 : MORE SOLUTIONS  (for 06_more_practice_questions.sql)
-- =====================================================================
USE window_fn_course;

-- Q1
SELECT product_name, price,
       COUNT(*) OVER () AS total_products          -- 10
FROM products;

-- Q2
SELECT product_name, price,
       AVG(price) OVER () AS avg_price             -- 12900
FROM products;

-- Q3
SELECT product_name, price,
       MIN(price) OVER () AS cheapest_price,       -- 500
       MAX(price) OVER () AS costliest_price       -- 55000
FROM products;

-- Q4
SELECT product_name, units_sold,
       SUM(units_sold) OVER () AS total_units      -- 329
FROM products;

-- Q5
SELECT product_name, price,
       MAX(price) OVER () - MIN(price) OVER () AS price_range   -- 54500
FROM products;

-- Q6
SELECT product_name, price, units_sold,
       price * units_sold                AS revenue,
       SUM(price * units_sold) OVER ()   AS total_revenue       -- 1945000
FROM products;

-- Q7
SELECT product_name,
       price * units_sold AS revenue,
       ROUND(price * units_sold * 100.0 / SUM(price * units_sold) OVER (), 2) AS pct_of_revenue
FROM products;

-- Q8
SELECT product_name, units_sold,
       ROUND(AVG(units_sold) OVER (), 1)              AS avg_units,       -- 32.9
       ROUND(units_sold - AVG(units_sold) OVER (), 1) AS diff_from_avg
FROM products;

-- Q9
SELECT product_name, price,
       ROUND(price * 100.0 / MAX(price) OVER (), 2) AS pct_of_costliest
FROM products;

-- Q10
SELECT product_name, price,
       CASE
           WHEN price > AVG(price) OVER () THEN 'Premium'
           ELSE 'Budget'
       END AS price_segment
FROM products;

-- Q11  (WHERE runs first, so the window only sees Clothing rows)
SELECT product_name, category, units_sold,
       SUM(units_sold) OVER () AS clothing_units   -- 185
FROM products
WHERE category = 'Clothing';

-- Q12  (calculate the window in a subquery, filter outside)
SELECT product_name, price, avg_price
FROM (
    SELECT product_name, price,
           AVG(price) OVER () AS avg_price
    FROM products
) AS t
WHERE price > avg_price;
-- Result: Laptop, Mobile, Sofa

-- Q13
SELECT product_name, revenue, pct_of_revenue
FROM (
    SELECT product_name,
           price * units_sold AS revenue,
           ROUND(price * units_sold * 100.0 / SUM(price * units_sold) OVER (), 2) AS pct_of_revenue
    FROM products
) AS t
WHERE pct_of_revenue > 10;
-- Result: Laptop (33.93%), Mobile (30.85%)

-- Q14
SELECT product_name, price,
       SUM(CASE WHEN price > 5000 THEN 1 ELSE 0 END) OVER () AS products_above_5000   -- 4
FROM products;

-- Q15
SELECT emp_name, salary,
       ROUND(salary * 1.10, 0)            AS new_salary,
       ROUND(SUM(salary * 1.10) OVER (), 0) AS new_company_total   -- 980100
FROM employees;

-- Q16
SELECT emp_name, salary, company_avg
FROM (
    SELECT emp_name, salary,
           ROUND(AVG(salary) OVER (), 0) AS company_avg            -- 59400
    FROM employees
) AS t
WHERE salary > company_avg;
-- Result: 7 employees (Kabir, Ananya, Vivaan, Isha, Priya, Rahul, Neel)

-- Q17  (check the highest first, otherwise the top earner would get 'Above Avg')
SELECT emp_name, salary,
       ROUND(AVG(salary) OVER (), 0) AS company_avg,
       CASE
           WHEN salary = MAX(salary) OVER () THEN 'Top Earner'
           WHEN salary > AVG(salary) OVER () THEN 'Above Avg'
           ELSE 'Below Avg'
       END AS salary_label
FROM employees;

-- Q18
-- Error: window functions are calculated AFTER the WHERE clause runs,
-- so they cannot be used inside WHERE.
-- Order of execution: FROM -> WHERE -> GROUP BY -> HAVING -> window -> SELECT -> ORDER BY
-- Fix: calculate the window in a subquery and filter outside.
SELECT emp_name, salary
FROM (
    SELECT emp_name, salary,
           AVG(salary) OVER () AS company_avg
    FROM employees
) AS t
WHERE salary > company_avg;
