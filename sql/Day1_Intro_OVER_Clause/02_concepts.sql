-- =====================================================================
-- DAY 1 : INTRODUCTION — WHAT IS A WINDOW FUNCTION? THE OVER() CLAUSE
-- Dataset : employees  (run 00_simple_example.sql, then 01_dataset.sql)
-- =====================================================================
USE window_fn_course;

/* ---------------------------------------------------------------------
   1. WHAT IS A WINDOW FUNCTION?
   ---------------------------------------------------------------------
   A window function performs a calculation across a set of rows
   ("the window") that are related to the current row —
   BUT it does NOT collapse the rows like GROUP BY does.

   GROUP BY  -> many rows become ONE row per group.
   WINDOW    -> every row stays, and you get an extra calculated column.

   Syntax:
       function_name(column) OVER ( [PARTITION BY ...] [ORDER BY ...] [frame] )

   Today  : OVER()              -> the whole table is the window
   Day 2  : PARTITION BY        -> one window per group
   Day 3+ : ORDER BY and frames
--------------------------------------------------------------------- */


-- 1A. GROUP BY: total company salary (15 rows collapse into 1 row)
SELECT SUM(salary) AS company_total
FROM employees;

-- 1B. GROUP BY: average salary per department (15 rows -> 4 rows)
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- 1C. Problem: show each employee AND the company total.
--     This gives an ERROR (or wrong result) because emp_name is not grouped:
-- SELECT emp_name, salary, SUM(salary) FROM employees;

--     Window function solves it — all 15 rows are kept:
SELECT emp_name, salary,
       SUM(salary) OVER () AS company_total
FROM employees;


/* ---------------------------------------------------------------------
   2. EMPTY OVER()  -> the window is the WHOLE table
      Every aggregate function can be used this way.
--------------------------------------------------------------------- */
SELECT emp_name, salary,
       COUNT(*)    OVER () AS total_employees,
       SUM(salary) OVER () AS company_total,
       AVG(salary) OVER () AS company_avg,
       MIN(salary) OVER () AS company_min,
       MAX(salary) OVER () AS company_max
FROM employees;


/* ---------------------------------------------------------------------
   3. USING THE WINDOW RESULT IN A CALCULATION
      This is where window functions become really useful.
--------------------------------------------------------------------- */

-- 3A. Each employee's salary as % of the total company salary
SELECT emp_name, salary,
       ROUND(salary * 100.0 / SUM(salary) OVER (), 2) AS pct_of_total
FROM employees;

-- 3B. How far is each salary from the company average?
SELECT emp_name, salary,
       ROUND(AVG(salary) OVER (), 0)          AS company_avg,
       ROUND(salary - AVG(salary) OVER (), 0) AS diff_from_avg
FROM employees;

-- 3C. Gap between each employee and the highest-paid employee
SELECT emp_name, salary,
       MAX(salary) OVER () - salary AS gap_from_top
FROM employees;

-- 3D. Label each employee using the window result
SELECT emp_name, salary,
       CASE
           WHEN salary >= AVG(salary) OVER () THEN 'Above company avg'
           ELSE 'Below company avg'
       END AS salary_band
FROM employees;


/* ---------------------------------------------------------------------
   4. WINDOW + WHERE
      WHERE runs FIRST, so the window only sees the filtered rows.
--------------------------------------------------------------------- */
SELECT emp_name, department, salary,
       SUM(salary) OVER () AS it_total      -- total of IT only, not the company
FROM employees
WHERE department = 'IT';


/* ---------------------------------------------------------------------
   KEY POINTS TO REMEMBER
   - Window functions keep all rows; GROUP BY collapses them.
   - OVER() with nothing inside -> the whole result set is one window.
   - SUM, AVG, COUNT, MIN, MAX can all be used with OVER().
   - WHERE is applied before the window is calculated.
--------------------------------------------------------------------- */
