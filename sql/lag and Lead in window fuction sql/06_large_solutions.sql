-- =====================================================================
-- LAG & LEAD : REAL-WORLD SOLUTIONS (LARGE DATASET)  -  LOW TO HIGH
-- Database : lag_lead_real
-- =====================================================================
USE lag_lead_real;


-- =====================================================================
-- LEVEL 1 : VERY EASY   (table: shop_sales, 7 rows)
-- =====================================================================

-- Q1. Yesterday's sales  -> LAG pulls the value DOWN by one row
SELECT day_name, sales,
       LAG(sales) OVER (ORDER BY sale_date) AS prev_day_sales
FROM shop_sales;
-- Expected:
--   day_name  | sales | prev_day_sales
--   Monday    | 1000  | NULL   <- Monday has no day before it
--   Tuesday   | 1200  | 1000
--   Wednesday |  900  | 1200
--   Thursday  | 1500  |  900
--   Friday    | 1500  | 1500
--   Saturday  | 2000  | 1500
--   Sunday    | 1800  | 2000

-- Q2. Tomorrow's sales  -> LEAD pulls the value UP by one row
SELECT day_name, sales,
       LEAD(sales) OVER (ORDER BY sale_date) AS next_day_sales
FROM shop_sales;
-- Expected:
--   day_name  | sales | next_day_sales
--   Monday    | 1000  | 1200
--   Tuesday   | 1200  |  900
--   Wednesday |  900  | 1500
--   Thursday  | 1500  | 1500
--   Friday    | 1500  | 2000
--   Saturday  | 2000  | 1800
--   Sunday    | 1800  | NULL   <- Sunday has no day after it

-- Q3. Default value 0 instead of NULL
SELECT day_name, sales,
       LAG(sales, 1, 0) OVER (ORDER BY sale_date) AS prev_day_sales
FROM shop_sales;
-- Expected: same as Q1, but Monday shows 0 instead of NULL

-- Q4. Sales of 2 days before  (offset = 2)
SELECT day_name, sales,
       LAG(sales, 2) OVER (ORDER BY sale_date) AS sales_2_days_ago
FROM shop_sales;
-- Expected:
--   day_name  | sales | sales_2_days_ago
--   Monday    | 1000  | NULL
--   Tuesday   | 1200  | NULL   <- only 1 day before Tuesday, not 2
--   Wednesday |  900  | 1000
--   Thursday  | 1500  | 1200
--   Friday    | 1500  |  900
--   Saturday  | 2000  | 1500
--   Sunday    | 1800  | 1500

-- Q5. Yesterday and tomorrow side by side
SELECT day_name,
       LAG(sales)  OVER (ORDER BY sale_date) AS prev_day_sales,
       sales,
       LEAD(sales) OVER (ORDER BY sale_date) AS next_day_sales
FROM shop_sales;
-- Expected:
--   day_name  | prev_day_sales | sales | next_day_sales
--   Monday    | NULL           | 1000  | 1200
--   Tuesday   | 1000           | 1200  |  900
--   Wednesday | 1200           |  900  | 1500
--   Thursday  |  900           | 1500  | 1500
--   Friday    | 1500           | 1500  | 2000
--   Saturday  | 1500           | 2000  | 1800
--   Sunday    | 2000           | 1800  | NULL

-- Q6. Change compared with yesterday
SELECT day_name, sales,
       LAG(sales) OVER (ORDER BY sale_date)         AS prev_day_sales,
       sales - LAG(sales) OVER (ORDER BY sale_date) AS change_from_yesterday
FROM shop_sales;
-- Expected:
--   day_name  | sales | prev_day_sales | change_from_yesterday
--   Monday    | 1000  | NULL           | NULL   <- anything minus NULL = NULL
--   Tuesday   | 1200  | 1000           |  200
--   Wednesday |  900  | 1200           | -300
--   Thursday  | 1500  |  900           |  600
--   Friday    | 1500  | 1500           |    0
--   Saturday  | 2000  | 1500           |  500
--   Sunday    | 1800  | 2000           | -200


-- =====================================================================
-- LEVEL 2 : EASY
-- =====================================================================

-- Q7. Previous close for every stock
SELECT symbol, trade_date, close_price,
       LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
FROM stock_daily;

-- Q8. Next close for every stock
SELECT symbol, trade_date, close_price,
       LEAD(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS next_close
FROM stock_daily;

-- Q9. Previous month's revenue per region
SELECT region, sales_month, revenue,
       LAG(revenue) OVER (PARTITION BY region ORDER BY sales_month) AS prev_revenue
FROM monthly_sales;

-- Q10. Previous salary per employee
SELECT emp_id, emp_name, effective_date, annual_salary,
       LAG(annual_salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
FROM salary_history;

-- Q11. Previous order date per customer
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_order_date
FROM orders
WHERE order_status = 'Delivered';

-- Q12. Next order's category per customer
SELECT customer_id, order_id, order_date, category,
       LEAD(category) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS next_category
FROM orders
WHERE order_status = 'Delivered';


-- =====================================================================
-- LEVEL 3 : MEDIUM
-- =====================================================================

-- Q13. Change in active users
SELECT activity_date, active_users,
       active_users - LAG(active_users) OVER (ORDER BY activity_date) AS change_in_users
FROM app_daily_users;

-- Q14. Day-over-day change %
WITH a AS (
    SELECT activity_date, active_users,
           LAG(active_users) OVER (ORDER BY activity_date) AS prev_users
    FROM app_daily_users
)
SELECT activity_date, active_users, prev_users,
       ROUND((active_users - prev_users) * 100 / prev_users, 2) AS dod_change_pct
FROM a
ORDER BY activity_date;

-- Q15. Daily change in rupees and %
WITH p AS (
    SELECT symbol, trade_date, close_price,
           LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
    FROM stock_daily
)
SELECT symbol, trade_date, close_price, prev_close,
       ROUND(close_price - prev_close, 2)                      AS change_rs,
       ROUND((close_price - prev_close) * 100 / prev_close, 2) AS change_pct
FROM p
ORDER BY symbol, trade_date;

-- Q16. MoM growth %
WITH s AS (
    SELECT region, sales_month, revenue,
           LAG(revenue) OVER (PARTITION BY region ORDER BY sales_month) AS prev_revenue
    FROM monthly_sales
)
SELECT region, sales_month, revenue, prev_revenue,
       ROUND((revenue - prev_revenue) * 100 / prev_revenue, 2) AS mom_growth_pct
FROM s
ORDER BY region, sales_month;

-- Q17. Hike amount and hike %
WITH s AS (
    SELECT emp_id, emp_name, department, effective_date, annual_salary,
           LAG(annual_salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
    FROM salary_history
)
SELECT emp_id, emp_name, department, effective_date, prev_salary, annual_salary,
       annual_salary - prev_salary                                 AS hike_amount,
       ROUND((annual_salary - prev_salary) * 100 / prev_salary, 2) AS hike_pct,
       CASE WHEN prev_salary IS NULL THEN 'Joining' ELSE '' END    AS remark
FROM s
ORDER BY emp_id, effective_date;

-- Q18. Days since previous order
WITH o AS (
    SELECT customer_id, order_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_order_date
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT customer_id, order_id, order_date, prev_order_date,
       DATEDIFF(order_date, prev_order_date) AS days_since_prev
FROM o
ORDER BY customer_id, order_date;

-- Q19. Weekly return (5 trading days back)
WITH p AS (
    SELECT symbol, trade_date, close_price,
           LAG(close_price, 5) OVER (PARTITION BY symbol ORDER BY trade_date) AS close_5_days_ago
    FROM stock_daily
)
SELECT symbol, trade_date, close_price, close_5_days_ago,
       ROUND((close_price - close_5_days_ago) * 100 / close_5_days_ago, 2) AS weekly_return_pct
FROM p
WHERE close_5_days_ago IS NOT NULL
ORDER BY symbol, trade_date;

-- Q20. YoY growth (2024 vs same month 2023)
WITH s AS (
    SELECT region, sales_month, revenue,
           LAG(revenue, 12) OVER (PARTITION BY region ORDER BY sales_month) AS revenue_last_year
    FROM monthly_sales
)
SELECT region, sales_month, revenue, revenue_last_year,
       ROUND((revenue - revenue_last_year) * 100 / revenue_last_year, 2) AS yoy_growth_pct
FROM s
WHERE revenue_last_year IS NOT NULL
ORDER BY region, sales_month;
-- LAG(revenue, 12) works here only because EVERY month exists for every region


-- =====================================================================
-- LEVEL 4 : MEDIUM-HARD
-- =====================================================================

-- Q21. Trend label
WITH p AS (
    SELECT symbol, trade_date, close_price,
           LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
    FROM stock_daily
)
SELECT symbol, trade_date, close_price, prev_close,
       CASE
           WHEN prev_close IS NULL       THEN 'First Day'
           WHEN close_price > prev_close THEN 'Up'
           WHEN close_price < prev_close THEN 'Down'
           ELSE 'Same'
       END AS trend
FROM p
ORDER BY symbol, trade_date;

-- Q22. Spent more / less than the previous order
WITH o AS (
    SELECT customer_id, order_id, order_date, amount,
           LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_amount
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT customer_id, order_id, order_date, prev_amount, amount,
       CASE
           WHEN prev_amount IS NULL  THEN 'First Order'
           WHEN amount > prev_amount THEN 'Spent More'
           WHEN amount < prev_amount THEN 'Spent Less'
           ELSE 'Same'
       END AS spending_trend
FROM o
ORDER BY customer_id, order_date;

-- Q23. Number of "up" days per stock
WITH p AS (
    SELECT symbol, close_price,
           LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
    FROM stock_daily
)
SELECT symbol, COUNT(*) AS up_days
FROM p
WHERE close_price > prev_close
GROUP BY symbol
ORDER BY up_days DESC;

-- Q24. Gap up of more than 1%
WITH p AS (
    SELECT symbol, trade_date, open_price,
           LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
    FROM stock_daily
)
SELECT symbol, trade_date, prev_close, open_price,
       ROUND((open_price - prev_close) * 100 / prev_close, 2) AS gap_pct
FROM p
WHERE (open_price - prev_close) * 100 / prev_close > 1
ORDER BY gap_pct DESC;

-- Q25. Promotions (designation changed)
WITH s AS (
    SELECT emp_id, emp_name, effective_date, designation, annual_salary,
           LAG(designation)   OVER w AS prev_designation,
           LAG(annual_salary) OVER w AS prev_salary
    FROM salary_history
    WINDOW w AS (PARTITION BY emp_id ORDER BY effective_date)
)
SELECT emp_id, emp_name, effective_date,
       prev_designation AS old_designation,
       designation      AS new_designation,
       ROUND((annual_salary - prev_salary) * 100 / prev_salary, 2) AS hike_pct
FROM s
WHERE designation <> prev_designation
ORDER BY emp_id, effective_date;

-- Q26. Pay cuts
WITH s AS (
    SELECT emp_id, emp_name, department, effective_date, annual_salary,
           LAG(annual_salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
    FROM salary_history
)
SELECT emp_id, emp_name, department, effective_date, prev_salary, annual_salary,
       ROUND((annual_salary - prev_salary) * 100 / prev_salary, 2) AS cut_pct
FROM s
WHERE annual_salary < prev_salary
ORDER BY cut_pct;

-- Q27. Zero hike revisions
WITH s AS (
    SELECT emp_id, emp_name, effective_date, annual_salary,
           LAG(annual_salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
    FROM salary_history
)
SELECT emp_id, emp_name, effective_date, annual_salary
FROM s
WHERE annual_salary = prev_salary
ORDER BY emp_id, effective_date;

-- Q28. Category switching
WITH o AS (
    SELECT customer_id, order_id, order_date, category,
           LAG(category) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_category
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT customer_id, order_id, order_date, prev_category, category,
       CASE
           WHEN prev_category IS NULL    THEN 'First Order'
           WHEN prev_category = category THEN 'Same'
           ELSE 'Switched'
       END AS category_change
FROM o
ORDER BY customer_id, order_date;

--      ...and the count of switches per customer
WITH o AS (
    SELECT customer_id, category,
           LAG(category) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_category
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT customer_id,
       SUM(CASE WHEN prev_category <> category THEN 1 ELSE 0 END) AS times_switched
FROM o
GROUP BY customer_id
ORDER BY times_switched DESC;

-- Q29. Days since last order (inactive > 60 days)
WITH o AS (
    SELECT customer_id, order_date,
           LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS next_order_date
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT o.customer_id, c.customer_name,
       o.order_date                         AS last_order_date,
       DATEDIFF('2024-12-31', o.order_date) AS days_inactive
FROM o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.next_order_date IS NULL
  AND DATEDIFF('2024-12-31', o.order_date) > 60
ORDER BY days_inactive DESC;

-- Q30. Missing dates (gaps)
WITH a AS (
    SELECT activity_date,
           LEAD(activity_date) OVER (ORDER BY activity_date) AS next_date
    FROM app_daily_users
)
SELECT activity_date AS last_date_before_gap,
       next_date     AS first_date_after_gap,
       DATEDIFF(next_date, activity_date) - 1 AS missing_days
FROM a
WHERE DATEDIFF(next_date, activity_date) > 1
ORDER BY activity_date;
-- Expected: 5 gaps, 8 missing days in total (Jan-14, Feb-09/10, Mar-03, Apr-21/22/23, May-30)


-- =====================================================================
-- LEVEL 5 : HARD
-- =====================================================================

-- Q31. Top 5 biggest single-day % gains
WITH p AS (
    SELECT symbol, trade_date, close_price,
           LAG(close_price) OVER (PARTITION BY symbol ORDER BY trade_date) AS prev_close
    FROM stock_daily
)
SELECT symbol, trade_date, prev_close, close_price,
       ROUND((close_price - prev_close) * 100 / prev_close, 2) AS gain_pct
FROM p
WHERE prev_close IS NOT NULL
ORDER BY gain_pct DESC
LIMIT 5;

-- Q32. Top 3 biggest one-day jumps
WITH a AS (
    SELECT activity_date, active_users,
           LAG(active_users) OVER (ORDER BY activity_date) AS prev_users
    FROM app_daily_users
)
SELECT activity_date, prev_users, active_users,
       active_users - prev_users AS jump
FROM a
ORDER BY jump DESC
LIMIT 3;
-- 2024-03-15 (campaign start) is the top row

-- Q33. Close went up 3 days in a row
WITH p AS (
    SELECT symbol, trade_date, close_price,
           LAG(close_price, 1) OVER w AS c1,
           LAG(close_price, 2) OVER w AS c2,
           LAG(close_price, 3) OVER w AS c3
    FROM stock_daily
    WINDOW w AS (PARTITION BY symbol ORDER BY trade_date)
)
SELECT symbol, trade_date, c3, c2, c1, close_price
FROM p
WHERE close_price > c1 AND c1 > c2 AND c2 > c3
ORDER BY symbol, trade_date;

-- Q34. Active users dropped 3 days in a row
WITH a AS (
    SELECT activity_date, active_users,
           LAG(active_users, 1) OVER w AS u1,
           LAG(active_users, 2) OVER w AS u2,
           LAG(active_users, 3) OVER w AS u3
    FROM app_daily_users
    WINDOW w AS (ORDER BY activity_date)
)
SELECT activity_date, u3, u2, u1, active_users
FROM a
WHERE active_users < u1 AND u1 < u2 AND u2 < u3
ORDER BY activity_date;

-- Q35. Revenue dropped 2 months in a row
WITH s AS (
    SELECT region, sales_month, revenue,
           LAG(revenue, 1) OVER w AS prev_1,
           LAG(revenue, 2) OVER w AS prev_2
    FROM monthly_sales
    WINDOW w AS (PARTITION BY region ORDER BY sales_month)
)
SELECT region, sales_month, prev_2, prev_1, revenue
FROM s
WHERE revenue < prev_1 AND prev_1 < prev_2
ORDER BY region, sales_month;

-- Q36. Average gap between orders (customers with 3+ orders)
WITH o AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_order_date
    FROM orders
    WHERE order_status = 'Delivered'
),
g AS (
    SELECT customer_id, DATEDIFF(order_date, prev_order_date) AS gap_days
    FROM o
)
SELECT g.customer_id, c.customer_name,
       COUNT(*)                AS total_orders,
       ROUND(AVG(gap_days), 1) AS avg_days_between_orders
FROM g
JOIN customers c ON c.customer_id = g.customer_id
GROUP BY g.customer_id, c.customer_name
HAVING COUNT(*) >= 3
ORDER BY avg_days_between_orders;
-- note: AVG ignores the NULL gap of each customer's first order

-- Q37. Longest gap per customer, more than 90 days
WITH o AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS prev_order_date
    FROM orders
    WHERE order_status = 'Delivered'
),
g AS (
    SELECT customer_id, DATEDIFF(order_date, prev_order_date) AS gap_days
    FROM o
)
SELECT g.customer_id, c.customer_name, c.city, MAX(gap_days) AS longest_gap_days
FROM g
JOIN customers c ON c.customer_id = g.customer_id
GROUP BY g.customer_id, c.customer_name, c.city
HAVING MAX(gap_days) > 90
ORDER BY longest_gap_days DESC;

-- Q38. 1st order, 2nd order and the gap between them
WITH o AS (
    SELECT customer_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS order_no,
           LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS next_order_date
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT customer_id,
       order_date      AS first_order_date,
       next_order_date AS second_order_date,
       DATEDIFF(next_order_date, order_date) AS days_to_second_order
FROM o
WHERE order_no = 1
ORDER BY customer_id;
-- customers with only one order show NULL for the second order

-- Q39. New order within 3 days after a Cancelled / Returned order (all statuses)
WITH o AS (
    SELECT customer_id, order_id, order_date, order_status,
           LEAD(order_id)   OVER w AS next_order_id,
           LEAD(order_date) OVER w AS next_order_date
    FROM orders
    WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)
)
SELECT customer_id, order_id, order_date, order_status,
       next_order_id, next_order_date,
       DATEDIFF(next_order_date, order_date) AS days_to_reorder
FROM o
WHERE order_status IN ('Cancelled', 'Returned')
  AND DATEDIFF(next_order_date, order_date) <= 3
ORDER BY customer_id;
-- Expected: 4 rows (customers 44, 110, 115, 117)

-- Q40. Volume spike and the next day's move
WITH p AS (
    SELECT symbol, trade_date, close_price, volume,
           LAG(volume)       OVER w AS prev_volume,
           LEAD(close_price) OVER w AS next_close
    FROM stock_daily
    WINDOW w AS (PARTITION BY symbol ORDER BY trade_date)
)
SELECT symbol, trade_date, prev_volume, volume,
       ROUND(volume / prev_volume, 2)                           AS volume_x,
       ROUND((next_close - close_price) * 100 / close_price, 2) AS next_day_change_pct
FROM p
WHERE volume > 2 * prev_volume
ORDER BY volume_x DESC;

-- Q41. Marketing spend up but revenue down
WITH s AS (
    SELECT region, sales_month, revenue, marketing_spend,
           LAG(revenue)         OVER w AS prev_revenue,
           LAG(marketing_spend) OVER w AS prev_spend
    FROM monthly_sales
    WINDOW w AS (PARTITION BY region ORDER BY sales_month)
)
SELECT region, sales_month,
       ROUND(marketing_spend - prev_spend, 2) AS spend_change,
       ROUND(revenue - prev_revenue, 2)       AS revenue_change,
       CASE WHEN marketing_spend > prev_spend AND revenue < prev_revenue
            THEN 'Check Campaign' ELSE '' END AS flag
FROM s
WHERE prev_revenue IS NOT NULL
ORDER BY region, sales_month;

-- Q42. November -> December change
WITH s AS (
    SELECT region, sales_month, revenue,
           LEAD(revenue) OVER (PARTITION BY region ORDER BY sales_month) AS next_month_revenue
    FROM monthly_sales
)
SELECT region, YEAR(sales_month) AS yr,
       revenue            AS nov_revenue,
       next_month_revenue AS dec_revenue,
       ROUND((next_month_revenue - revenue) * 100 / revenue, 2) AS change_pct
FROM s
WHERE MONTH(sales_month) = 11
ORDER BY change_pct;
-- the first row is the biggest drop (North, 2024)

-- Q43. Best month per region per year and its % increase over the month before
WITH s AS (
    SELECT region, sales_month, revenue,
           LAG(revenue) OVER (PARTITION BY region ORDER BY sales_month) AS prev_revenue,
           RANK() OVER (PARTITION BY region, YEAR(sales_month) ORDER BY revenue DESC) AS rnk
    FROM monthly_sales
)
SELECT region, YEAR(sales_month) AS yr, sales_month AS best_month, revenue, prev_revenue,
       ROUND((revenue - prev_revenue) * 100 / prev_revenue, 2) AS pct_over_prev_month
FROM s
WHERE rnk = 1
ORDER BY region, yr;

-- Q44. Highest hike % per department
WITH s AS (
    SELECT emp_id, emp_name, department, effective_date, annual_salary,
           LAG(annual_salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
    FROM salary_history
),
h AS (
    SELECT *,
           ROUND((annual_salary - prev_salary) * 100 / prev_salary, 2) AS hike_pct
    FROM s
    WHERE prev_salary IS NOT NULL
),
r AS (
    SELECT *, RANK() OVER (PARTITION BY department ORDER BY hike_pct DESC) AS rnk
    FROM h
)
SELECT department, emp_id, emp_name, effective_date, hike_pct
FROM r
WHERE rnk = 1
ORDER BY department;

-- Q45. Years from joining to first promotion
WITH s AS (
    SELECT emp_id, emp_name, effective_date, designation,
           LAG(designation) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_designation,
           FIRST_VALUE(effective_date) OVER (PARTITION BY emp_id ORDER BY effective_date) AS joining_date
    FROM salary_history
),
p AS (
    SELECT emp_id, emp_name, joining_date, effective_date AS promotion_date,
           ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY effective_date) AS promo_no
    FROM s
    WHERE designation <> prev_designation
)
SELECT emp_id, emp_name, joining_date, promotion_date AS first_promotion_date,
       ROUND(DATEDIFF(promotion_date, joining_date) / 365, 1) AS years_to_promotion
FROM p
WHERE promo_no = 1
ORDER BY years_to_promotion;

-- Q46. Same day last week
-- WHY LAG(active_users, 7) IS WRONG:
--   LAG counts ROWS, not DAYS. Because some dates are missing, "7 rows back"
--   is sometimes 8, 9 or 10 days back - not the same weekday.
--   Example: for 2024-04-28, 7 rows back is 2024-04-18, not 2024-04-21.
-- CORRECT: match on the actual date with a self join.
SELECT t.activity_date,
       t.active_users,
       lw.activity_date AS same_day_last_week,
       lw.active_users  AS last_week_users,
       ROUND((t.active_users - lw.active_users) * 100 / lw.active_users, 2) AS wow_change_pct
FROM app_daily_users t
LEFT JOIN app_daily_users lw
       ON lw.activity_date = DATE_SUB(t.activity_date, INTERVAL 7 DAY)
ORDER BY t.activity_date;
-- last_week_users is NULL when last week's date is one of the missing days
