-- =====================================================================
--  WINDOW FUNCTIONS IN MYSQL - 12 EXAMPLES (for Data Analyst students)
-- =====================================================================
--  What is a Window Function?
--  A function that does a calculation across a set of rows that are
--  related to the current row (the "window") - BUT, unlike GROUP BY,
--  it does NOT collapse the rows. Every row stays in the result and
--  gets an extra calculated column.
--
--  GROUP BY       -> 13 employees in, 4 rows out (one per department)
--  Window (OVER)  -> 13 employees in, 13 rows out (each with dept total)
--
--  Syntax:
--      function_name(...) OVER (
--          PARTITION BY col      -- split rows into groups (optional)
--          ORDER BY col          -- order rows inside each group (optional)
--          ROWS BETWEEN ...      -- frame: which rows to look at (optional)
--      )
--
--  Types of window functions:
--      Ranking     -> ROW_NUMBER, RANK, DENSE_RANK, NTILE
--      Aggregate   -> SUM, AVG, COUNT, MIN, MAX  (with OVER)
--      Value       -> LAG, LEAD, FIRST_VALUE, LAST_VALUE
--      Distribution-> PERCENT_RANK, CUME_DIST
--
--  NOTE: Window functions need MySQL 8.0 or above.
--        They can be used in SELECT and ORDER BY, but NOT in WHERE.
--        (To filter on them, wrap the query in a CTE / subquery.)
-- =====================================================================


-- =====================================================================
--  STEP 1 : DATASET
-- =====================================================================
DROP DATABASE IF EXISTS window_db;
CREATE DATABASE window_db;
USE window_db;

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_name   VARCHAR(50),
    department VARCHAR(30),
    salary     DECIMAL(10,2),
    hire_date  DATE
);

CREATE TABLE monthly_sales (
    sale_month DATE,                  -- first day of the month
    region     VARCHAR(20),
    revenue    DECIMAL(12,2)
);

-- Some salaries are equal on purpose, to show RANK vs DENSE_RANK
INSERT INTO employees (emp_name, department, salary, hire_date) VALUES
('Rahul',  'Sales',     30000, '2021-03-15'),
('Meera',  'Sales',     35000, '2020-07-01'),
('Arjun',  'Sales',     35000, '2022-01-10'),
('Neha',   'Sales',     28000, '2023-05-20'),
('Suresh', 'IT',        60000, '2019-11-11'),
('Kavita', 'IT',        65000, '2018-02-25'),
('Rohit',  'IT',        65000, '2021-09-30'),
('Amit',   'IT',        50000, '2023-08-14'),
('Deepak', 'HR',        40000, '2020-04-18'),
('Pooja',  'HR',        42000, '2022-06-06'),
('Ritu',   'Marketing', 45000, '2019-12-01'),
('Karan',  'Marketing', 48000, '2021-02-14'),
('Sneha',  'Marketing', 45000, '2024-01-08');

INSERT INTO monthly_sales (sale_month, region, revenue) VALUES
('2025-01-01', 'North', 120000),
('2025-02-01', 'North', 135000),
('2025-03-01', 'North', 128000),
('2025-04-01', 'North', 150000),
('2025-05-01', 'North', 162000),
('2025-06-01', 'North', 158000),
('2025-01-01', 'South',  90000),
('2025-02-01', 'South',  95000),
('2025-03-01', 'South', 110000),
('2025-04-01', 'South', 105000),
('2025-05-01', 'South', 118000),
('2025-06-01', 'South', 125000);


-- =====================================================================
--  EXAMPLE 1 : GROUP BY vs Window Function
--  Task : Show every employee along with their department's total salary
-- =====================================================================

-- GROUP BY: only 4 rows, employee names are lost
SELECT department, SUM(salary) AS dept_total
FROM employees
GROUP BY department;

-- Window: all 13 rows, each with its department total
SELECT emp_name,
       department,
       salary,
       SUM(salary) OVER (PARTITION BY department) AS dept_total
FROM employees;


-- =====================================================================
--  EXAMPLE 2 : Aggregate window functions (SUM, AVG, COUNT, MAX)
--  Task : Compare each employee's salary with their department
-- =====================================================================
SELECT emp_name,
       department,
       salary,
       COUNT(*)              OVER (PARTITION BY department) AS dept_emp_count,
       ROUND(AVG(salary)     OVER (PARTITION BY department), 2) AS dept_avg,
       MAX(salary)           OVER (PARTITION BY department) AS dept_max,
       salary - ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS diff_from_avg,
       ROUND(salary * 100 / SUM(salary) OVER (PARTITION BY department), 2) AS pct_of_dept
FROM employees
ORDER BY department, salary DESC;

-- OVER () with nothing inside = the whole table is one window
SELECT emp_name,
       salary,
       ROUND(AVG(salary) OVER (), 2) AS company_avg
FROM employees;


-- =====================================================================
--  EXAMPLE 3 : ROW_NUMBER()
--  Task : Give each employee a serial number by salary (highest first)
--         Then restart the numbering inside each department
-- =====================================================================
SELECT emp_name,
       department,
       salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC, emp_name) AS overall_no
FROM employees;

SELECT emp_name,
       department,
       salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC, emp_name) AS dept_no
FROM employees;


-- =====================================================================
--  EXAMPLE 4 : ROW_NUMBER vs RANK vs DENSE_RANK
--  Task : See how each function treats equal salaries (ties)
-- =====================================================================
SELECT emp_name,
       salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC, emp_name) AS row_num,
       RANK()       OVER (ORDER BY salary DESC)           AS rnk,
       DENSE_RANK() OVER (ORDER BY salary DESC)           AS dense_rnk
FROM employees;

--  Output (first 8 rows):
--  emp_name | salary | row_num | rnk | dense_rnk
--  Kavita   | 65000  |    1    |  1  |    1
--  Rohit    | 65000  |    2    |  1  |    1
--  Suresh   | 60000  |    3    |  3  |    2      <- RANK skips 2
--  Amit     | 50000  |    4    |  4  |    3
--  Karan    | 48000  |    5    |  5  |    4
--  Ritu     | 45000  |    6    |  6  |    5
--  Sneha    | 45000  |    7    |  6  |    5
--  Pooja    | 42000  |    8    |  8  |    6      <- RANK skips 7
--
--  ROW_NUMBER -> always unique 1,2,3,...      (ties get different numbers)
--  RANK       -> ties share a rank, then GAP  (1,1,3)
--  DENSE_RANK -> ties share a rank, NO gap    (1,1,2)


-- =====================================================================
--  EXAMPLE 5 : Top-N per group (most asked interview question)
--  Task : Find the top 2 highest-paid employees in each department
-- =====================================================================
-- Window functions are not allowed in WHERE, so use a CTE
WITH ranked AS (
    SELECT emp_name,
           department,
           salary,
           DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT *
FROM ranked
WHERE rnk <= 2;

-- Same idea: 2nd highest salary in the company
WITH ranked AS (
    SELECT emp_name, salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT * FROM ranked WHERE rnk = 2;


-- =====================================================================
--  EXAMPLE 6 : Running total (cumulative sum)
--  Task : Show month-wise revenue and running total for each region
-- =====================================================================
SELECT region,
       sale_month,
       revenue,
       SUM(revenue) OVER (PARTITION BY region ORDER BY sale_month) AS running_total
FROM monthly_sales;

-- Adding ORDER BY inside OVER() changes SUM from "total of the group"
-- to "total from the first row up to the current row".


-- =====================================================================
--  EXAMPLE 7 : Moving average (window frame with ROWS BETWEEN)
--  Task : 3-month moving average of revenue for each region
-- =====================================================================
SELECT region,
       sale_month,
       revenue,
       ROUND(AVG(revenue) OVER (
                 PARTITION BY region
                 ORDER BY sale_month
                 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
             ), 2) AS moving_avg_3m
FROM monthly_sales;

--  Frame options:
--      UNBOUNDED PRECEDING -> from the first row of the partition
--      n PRECEDING         -> n rows before current row
--      CURRENT ROW         -> the current row
--      n FOLLOWING         -> n rows after current row
--      UNBOUNDED FOLLOWING -> till the last row of the partition


-- =====================================================================
--  EXAMPLE 8 : LAG() - look at the PREVIOUS row
--  Task : Month-over-month (MoM) revenue growth for each region
-- =====================================================================
SELECT region,
       sale_month,
       revenue,
       LAG(revenue) OVER (PARTITION BY region ORDER BY sale_month) AS prev_revenue,
       revenue - LAG(revenue) OVER (PARTITION BY region ORDER BY sale_month) AS change_amt,
       ROUND(
           (revenue - LAG(revenue) OVER (PARTITION BY region ORDER BY sale_month)) * 100
           / LAG(revenue) OVER (PARTITION BY region ORDER BY sale_month)
       , 2) AS growth_pct
FROM monthly_sales;

-- The first month of each region has no previous row -> NULL
-- LAG(revenue, 1, 0) would return 0 instead of NULL (3rd arg = default)


-- =====================================================================
--  EXAMPLE 9 : LEAD() - look at the NEXT row
--  Task : Show each employee's hire date and the next hire in the
--         same department, plus the gap in days
-- =====================================================================
SELECT emp_name,
       department,
       hire_date,
       LEAD(hire_date) OVER (PARTITION BY department ORDER BY hire_date) AS next_hire_date,
       DATEDIFF(
           LEAD(hire_date) OVER (PARTITION BY department ORDER BY hire_date),
           hire_date
       ) AS days_gap
FROM employees;


-- =====================================================================
--  EXAMPLE 10 : FIRST_VALUE() and LAST_VALUE()
--  Task : Show the highest and lowest salary in each department
--         next to every employee
-- =====================================================================
SELECT emp_name,
       department,
       salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY salary DESC) AS dept_highest,
       LAST_VALUE(salary)  OVER (
                               PARTITION BY department ORDER BY salary DESC
                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                           ) AS dept_lowest
FROM employees;

-- TRAP: Without the ROWS BETWEEN ... UNBOUNDED FOLLOWING part,
-- LAST_VALUE only sees rows up to the current row, so it just
-- returns the current row's value. Always give LAST_VALUE a full frame.


-- =====================================================================
--  EXAMPLE 11 : NTILE() - split rows into N equal buckets
--  Task : Divide employees into 4 salary bands (quartiles)
-- =====================================================================
SELECT emp_name,
       salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS salary_band,
       CASE NTILE(4) OVER (ORDER BY salary DESC)
            WHEN 1 THEN 'Top 25%'
            WHEN 2 THEN 'Upper Middle'
            WHEN 3 THEN 'Lower Middle'
            ELSE        'Bottom 25%'
       END AS band_name
FROM employees;

-- 13 rows / 4 buckets -> bucket sizes 4, 3, 3, 3 (extra rows go to the first buckets)


-- =====================================================================
--  EXAMPLE 12 : PERCENT_RANK() and CUME_DIST() + named WINDOW
--  Task : Where does each employee's salary stand in the company?
-- =====================================================================
SELECT emp_name,
       salary,
       ROUND(PERCENT_RANK() OVER w * 100, 2) AS percent_rank_pct,
       ROUND(CUME_DIST()    OVER w * 100, 2) AS cume_dist_pct
FROM employees
WINDOW w AS (ORDER BY salary);

--  PERCENT_RANK -> (rank - 1) / (total rows - 1)   : 0 for the lowest
--  CUME_DIST    -> rows with value <= current / total rows
--  WINDOW w AS (...) lets you write the window once and reuse it.


-- =====================================================================
--  PRACTICE QUESTIONS
-- =====================================================================
--  1. Show each employee with the number of employees hired before them
--     in the same department (hint: ROW_NUMBER - 1 ordered by hire_date).
--  2. Find the lowest-paid employee in every department.
--  3. Show employees who earn more than their department's average.
--  4. For each region, find the month with the highest revenue.
--  5. Show each region's revenue as a % of that month's total revenue
--     (hint: PARTITION BY sale_month).
--  6. Find months where revenue went DOWN compared to the previous month.
--  7. Show a running count of employees hired, ordered by hire_date.
--  8. Find the 3rd highest salary using DENSE_RANK.
-- =====================================================================
