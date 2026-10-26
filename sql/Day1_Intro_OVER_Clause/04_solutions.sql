-- =====================================================================
-- DAY 1 : SOLUTIONS
-- =====================================================================
USE window_fn_course;

-- Q1
SELECT emp_name, salary,
       SUM(salary) OVER () AS company_total
FROM employees;

-- Q2
SELECT emp_name,
       COUNT(*) OVER () AS total_employees
FROM employees;

-- Q3
SELECT emp_name, salary,
       ROUND(AVG(salary) OVER (), 0) AS company_avg
FROM employees;

-- Q4
SELECT emp_name, salary,
       MAX(salary) OVER () AS highest_salary,
       MIN(salary) OVER () AS lowest_salary
FROM employees;

-- Q5
SELECT emp_name, salary,
       ROUND(salary * 100.0 / SUM(salary) OVER (), 2) AS pct_of_company
FROM employees;

-- Q6
SELECT emp_name, salary,
       ROUND(salary - AVG(salary) OVER (), 0) AS diff_from_avg
FROM employees;

-- Q7
SELECT emp_name, salary,
       MAX(salary) OVER () - salary AS gap_from_top
FROM employees;

-- Q8
SELECT emp_name, salary,
       ROUND(salary * 100.0 / MAX(salary) OVER (), 2) AS pct_of_top_salary
FROM employees;

-- Q9
SELECT emp_name, salary,
       CASE
           WHEN salary > AVG(salary) OVER () THEN 'Above Avg'
           ELSE 'Below Avg'
       END AS salary_flag
FROM employees;

-- Q10  (WHERE runs first, so the window only sees Delhi rows)
SELECT emp_name, city, salary,
       SUM(salary) OVER () AS delhi_total
FROM employees
WHERE city = 'Delhi';

-- Q11
SELECT AVG(salary) AS avg_salary FROM employees;              -- 1 row
SELECT emp_name, AVG(salary) OVER () AS avg_salary FROM employees;  -- 15 rows
-- GROUP BY / plain aggregate collapses all rows into one.
-- A window function keeps every row and repeats the result on each one.
