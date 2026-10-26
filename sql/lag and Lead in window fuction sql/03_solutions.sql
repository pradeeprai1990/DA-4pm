-- =====================================================================
-- LAG & LEAD : SOLUTIONS
-- Check only after you have tried 02_practice_questions.sql
-- =====================================================================
USE lag_lead_practice;


-- ============================ LEVEL 1 : EASY ============================

-- Q1. Previous day's close
SELECT stock_symbol, trade_date, close_price,
       LAG(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS prev_close
FROM stock_prices;

-- Q2. Next day's close
SELECT stock_symbol, trade_date, close_price,
       LEAD(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS next_close
FROM stock_prices;

-- Q3. Daily price change (first day of each stock is NULL)
SELECT stock_symbol, trade_date, close_price,
       close_price - LAG(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS price_change
FROM stock_prices;

-- Q4. Previous visits with default 0
SELECT visit_date, visits,
       LAG(visits, 1, 0) OVER (ORDER BY visit_date) AS prev_visits
FROM daily_visits;

-- Q5. Price from 2 trading days earlier (offset = 2)
SELECT stock_symbol, trade_date, close_price,
       LAG(close_price, 2) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS price_2_days_ago
FROM stock_prices;


-- ============================ LEVEL 2 : MEDIUM ==========================

-- Q6. Daily % change
SELECT stock_symbol, trade_date, close_price,
       ROUND(
         (close_price - LAG(close_price) OVER w) * 100 / LAG(close_price) OVER w
       , 2) AS pct_change
FROM stock_prices
WINDOW w AS (PARTITION BY stock_symbol ORDER BY trade_date);

-- Q7. Only the days the price went UP
WITH p AS (
    SELECT stock_symbol, trade_date, close_price,
           LAG(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS prev_close
    FROM stock_prices
)
SELECT *
FROM p
WHERE close_price > prev_close;
-- Expected: INFY 01-02, 01-05, 01-08 | TCS 01-03, 01-04, 01-05

-- Q8. Trend label
WITH p AS (
    SELECT stock_symbol, trade_date, close_price,
           LAG(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS prev_close
    FROM stock_prices
)
SELECT stock_symbol, trade_date, close_price, prev_close,
       CASE
           WHEN prev_close IS NULL       THEN 'First Day'
           WHEN close_price > prev_close THEN 'Up'
           WHEN close_price < prev_close THEN 'Down'
           ELSE 'Same'
       END AS trend
FROM p;

-- Q9. Salary hike %
WITH s AS (
    SELECT emp_id, emp_name, change_date, salary,
           LAG(salary) OVER (PARTITION BY emp_id ORDER BY change_date) AS prev_salary
    FROM salary_history
)
SELECT emp_id, emp_name, change_date, salary, prev_salary,
       ROUND((salary - prev_salary) * 100 / prev_salary, 2) AS hike_pct,
       CASE WHEN prev_salary IS NULL THEN 'Joined' ELSE '' END AS remark
FROM s;

-- Q10. Days since previous order
SELECT customer_id, order_id, order_date,
       DATEDIFF(order_date,
                LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_prev
FROM orders;

-- Q11. Next order date + days until next order
WITH o AS (
    SELECT customer_id, order_id, order_date,
           LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
    FROM orders
)
SELECT customer_id, order_id, order_date, next_order_date,
       DATEDIFF(next_order_date, order_date) AS days_to_next,
       CASE WHEN next_order_date IS NULL THEN 'Last Order' ELSE 'Reordered' END AS status
FROM o;

-- Q12. Score change vs previous exam
SELECT student, exam_no, score,
       score - LAG(score) OVER (PARTITION BY student ORDER BY exam_no) AS score_change
FROM exam_scores;


-- ============================ LEVEL 3 : HARD ============================

-- Q13. Missing dates (gaps) in daily_visits
WITH d AS (
    SELECT visit_date,
           LEAD(visit_date) OVER (ORDER BY visit_date) AS next_date
    FROM daily_visits
)
SELECT visit_date                         AS gap_starts_after,
       next_date                          AS gap_ends_before,
       DATEDIFF(next_date, visit_date) - 1 AS missing_days
FROM d
WHERE DATEDIFF(next_date, visit_date) > 1;
-- Expected: 2024-03-04 -> 2024-03-06 (1 day) | 2024-03-07 -> 2024-03-09 (1 day)

-- Q14. Price up 3 days in a row
WITH p AS (
    SELECT stock_symbol, trade_date, close_price,
           LAG(close_price, 1) OVER w AS p1,
           LAG(close_price, 2) OVER w AS p2,
           LAG(close_price, 3) OVER w AS p3
    FROM stock_prices
    WINDOW w AS (PARTITION BY stock_symbol ORDER BY trade_date)
)
SELECT stock_symbol, trade_date, close_price, p1, p2, p3
FROM p
WHERE close_price > p1 AND p1 > p2 AND p2 > p3;
-- Expected: TCS 2024-01-05 (3580 -> 3620 -> 3650 -> 3700)

-- Q15. Amount increased on every order
WITH o AS (
    SELECT customer_id, amount,
           LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_amount
    FROM orders
)
SELECT customer_id
FROM o
GROUP BY customer_id
HAVING COUNT(*) > 1
   AND SUM(CASE WHEN prev_amount IS NOT NULL AND amount <= prev_amount THEN 1 ELSE 0 END) = 0;
-- Expected: C2, C3

-- Q16. Gap of more than 60 days between orders
WITH o AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id, prev_date, order_date,
       DATEDIFF(order_date, prev_date) AS gap_days
FROM o
WHERE DATEDIFF(order_date, prev_date) > 60;
-- Expected: C3 (2024-01-10 -> 2024-05-20, 131 days)

-- Q17. Employees who got a pay cut
WITH s AS (
    SELECT emp_id, emp_name, change_date, salary,
           LAG(salary) OVER (PARTITION BY emp_id ORDER BY change_date) AS prev_salary
    FROM salary_history
)
SELECT DISTINCT emp_id, emp_name
FROM s
WHERE salary < prev_salary;
-- Expected: 103 Ravi

-- Q18. Biggest single-day gain per stock
WITH g AS (
    SELECT stock_symbol, trade_date,
           close_price - LAG(close_price) OVER (PARTITION BY stock_symbol ORDER BY trade_date) AS gain
    FROM stock_prices
),
r AS (
    SELECT *, RANK() OVER (PARTITION BY stock_symbol ORDER BY gain DESC) AS rnk
    FROM g
    WHERE gain IS NOT NULL
)
SELECT stock_symbol, trade_date, gain
FROM r
WHERE rnk = 1;
-- Expected: INFY 2024-01-05 (+35) | TCS 2024-01-05 (+50)

-- Q19. Students who improved in every exam
WITH e AS (
    SELECT student, score,
           LAG(score) OVER (PARTITION BY student ORDER BY exam_no) AS prev_score
    FROM exam_scores
)
SELECT student
FROM e
GROUP BY student
HAVING SUM(CASE WHEN prev_score IS NOT NULL AND score <= prev_score THEN 1 ELSE 0 END) = 0;
-- Expected: Meena

-- Q20. Days after which visits dropped (using LEAD)
WITH v AS (
    SELECT visit_date, visits,
           LEAD(visits) OVER (ORDER BY visit_date) AS next_visits
    FROM daily_visits
)
SELECT visit_date, visits, next_visits
FROM v
WHERE next_visits < visits;
-- Expected: 2024-03-03 (150 -> 140) | 2024-03-09 (190 -> 170)
