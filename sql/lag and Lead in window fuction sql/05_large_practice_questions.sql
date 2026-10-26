-- =====================================================================
-- LAG & LEAD : REAL-WORLD PRACTICE (LARGE DATASET)  -  LOW TO HIGH
-- Database : lag_lead_real   (run 04_large_dataset.sql first)
-- Tables   : stock_daily, customers, orders, monthly_sales,
--            salary_history, app_daily_users
-- Answers  : 06_large_solutions.sql  (try first!)
--
-- LEVEL 1  Very Easy   : only LAG / LEAD, no PARTITION BY
-- LEVEL 2  Easy        : LAG / LEAD with PARTITION BY
-- LEVEL 3  Medium      : calculations (difference, %, days between)
-- LEVEL 4  Medium-Hard : CASE labels + filtering with a CTE
-- LEVEL 5  Hard        : multi-step / interview-style problems
-- =====================================================================
USE lag_lead_real;

-- QUICK REMINDER
--   LAG(col, offset, default)  OVER (PARTITION BY ... ORDER BY ...) -> value from a PREVIOUS row
--   LEAD(col, offset, default) OVER (PARTITION BY ... ORDER BY ...) -> value from a NEXT row
--   offset  = how many rows back / forward (default 1)
--   default = value shown when there is no such row (default NULL)

-- First, look at the data:
-- SELECT * FROM shop_sales;
-- SELECT * FROM app_daily_users LIMIT 10;
-- SELECT * FROM stock_daily     LIMIT 10;
-- SELECT * FROM orders          LIMIT 10;
-- SELECT * FROM monthly_sales   LIMIT 10;
-- SELECT * FROM salary_history  LIMIT 10;


-- =====================================================================
-- LEVEL 1 : VERY EASY  (only LAG / LEAD, no PARTITION BY)
-- Table: shop_sales  -> only 7 rows, one week of a tea shop
--
--   sale_date   | day_name  | sales
--   ------------+-----------+------
--   2024-07-01  | Monday    | 1000
--   2024-07-02  | Tuesday   | 1200
--   2024-07-03  | Wednesday |  900
--   2024-07-04  | Thursday  | 1500
--   2024-07-05  | Friday    | 1500
--   2024-07-06  | Saturday  | 2000
--   2024-07-07  | Sunday    | 1800
--
-- Write the answer on paper first, then run your query and compare!
-- =====================================================================

-- Q1. Show day_name, sales and YESTERDAY's sales (prev_day_sales).
--     (Hint: LAG(sales) OVER (ORDER BY sale_date))
--     Which day gets NULL? Why?

-- Q2. Show day_name, sales and TOMORROW's sales (next_day_sales).
--     (Hint: LEAD)  Which day gets NULL now? Why?

-- Q3. Same as Q1, but show 0 instead of NULL for Monday.
--     (Hint: 3rd argument -> LAG(sales, 1, 0))

-- Q4. Show day_name, sales and the sales of 2 DAYS BEFORE (sales_2_days_ago).
--     (Hint: 2nd argument -> LAG(sales, 2))

-- Q5. Show yesterday's sales AND tomorrow's sales side by side:
--     day_name, prev_day_sales, sales, next_day_sales

-- Q6. Show how much sales went up or down compared with yesterday
--     (change = sales - yesterday's sales).


-- =====================================================================
-- LEVEL 2 : EASY  (LAG / LEAD with PARTITION BY)
-- =====================================================================

-- Q7. [stock_daily] For EVERY stock, show symbol, trade_date, close_price and
--     the previous day's close.  (The first day of each stock must be NULL.)

-- Q8. [stock_daily] For every stock, show the next day's close_price.

-- Q9. [monthly_sales] For every region, show each month's revenue and the
--     previous month's revenue.

-- Q10. [salary_history] For every employee, show each revision with the
--      previous salary.

-- Q11. [orders] For every customer, show each Delivered order with the
--      previous order date.

-- Q12. [orders] For every customer, show each Delivered order's category
--      and the category of their NEXT order.


-- =====================================================================
-- LEVEL 3 : MEDIUM  (calculations with LAG / LEAD)
-- =====================================================================

-- Q13. [app_daily_users] Show the change in active_users compared with the
--      previous row (active_users - prev_users).

-- Q14. [app_daily_users] Show the day-over-day change % (2 decimals).
--      Formula: (today - yesterday) * 100 / yesterday

-- Q15. [stock_daily] For every stock, show the daily change in rupees and
--      the daily change % (2 decimals).

-- Q16. [monthly_sales] For every region, show month-over-month (MoM)
--      revenue growth % (2 decimals).

-- Q17. [salary_history] Show every revision with prev_salary, hike_amount and
--      hike_pct. For each employee's first row show 'Joining' in a remark column.

-- Q18. [orders] For every customer, show the number of days since their
--      previous Delivered order.  (Hint: DATEDIFF.)

-- Q19. [stock_daily] Weekly return: compare each day's close with the close
--      5 trading days earlier and show the % return.

-- Q20. [monthly_sales] Year-over-year (YoY) growth: compare each month of 2024
--      with the SAME month of 2023 for every region.  (Hint: LAG(revenue, 12).)


-- =====================================================================
-- LEVEL 4 : MEDIUM-HARD  (CASE labels + filtering with a CTE)
-- Remember: you cannot use LAG / LEAD inside WHERE -> wrap it in a CTE.
-- =====================================================================

-- Q21. [stock_daily] Add a column 'trend' = 'Up' / 'Down' / 'Same' compared
--      with the previous day, and 'First Day' for the first row of each stock.

-- Q22. [orders] Label each Delivered order 'Spent More' / 'Spent Less' /
--      'First Order' compared with the customer's previous order amount.

-- Q23. [stock_daily] Count how many days each stock closed HIGHER than
--      the previous day.

-- Q24. [stock_daily] "Gap up" = today's OPEN is higher than yesterday's CLOSE.
--      List the days with a gap up of more than 1%.
--      Show symbol, trade_date, prev_close, open_price, gap_pct.

-- Q25. [salary_history] Detect promotions: rows where designation is different
--      from the previous designation. Show old & new designation and hike %.

-- Q26. [salary_history] List employees who got a pay CUT, with the date and cut %.

-- Q27. [salary_history] List the revisions where the salary did NOT change.

-- Q28. [orders] For each Delivered order, show 'Same' / 'Switched' compared with
--      the previous order's category. Then count switches per customer.

-- Q29. [orders] Using LEAD, find each customer's LAST Delivered order
--      (no next order) and the days passed until '2024-12-31'.
--      Show only customers inactive for more than 60 days.

-- Q30. [app_daily_users] Some dates are missing (tracking failed). Find
--      every gap: last date before the gap, first date after the gap and
--      the number of missing days.


-- =====================================================================
-- LEVEL 5 : HARD  (multi-step / interview-style)
-- =====================================================================

-- Q31. [stock_daily] Find the TOP 5 biggest single-day % gains across ALL stocks.

-- Q32. [app_daily_users] Find the TOP 3 biggest one-day jumps in active_users.
--      (One of them is the day a marketing campaign started!)

-- Q33. [stock_daily] Find every stock + date where the close price went up
--      3 days in a row (today > yesterday > day before > day before that).

-- Q34. [app_daily_users] Find the dates where active_users dropped 3 days in a row.

-- Q35. [monthly_sales] Find the months where revenue dropped 2 months in a row
--      in the same region.

-- Q36. [orders + customers] For customers with at least 3 Delivered orders,
--      find the AVERAGE days between orders. Sort from the most frequent buyer.

-- Q37. [orders + customers] Churn risk: find each customer's LONGEST gap
--      between two orders. List customers whose longest gap > 90 days.

-- Q38. [orders] For each customer show the 1st order date, 2nd order date and
--      the days between them. One row per customer.  (Hint: ROW_NUMBER + LEAD.)

-- Q39. [orders] (ALL statuses) Find customers who placed a new order within
--      3 days after a 'Cancelled' or 'Returned' order.

-- Q40. [stock_daily] Volume spike = volume more than 2x the previous day's volume.
--      For those days show the NEXT day's % price change.
--      (Hint: LAG for volume, LEAD for next close - in the same query.)

-- Q41. [monthly_sales] Show the change in marketing_spend and in revenue vs last
--      month. Flag months where spend went UP but revenue went DOWN.

-- Q42. [monthly_sales] Using LEAD, find the revenue change from November to
--      December for each region and year. Which region had the biggest drop?

-- Q43. [monthly_sales] For each region and year, show the best month and its
--      % increase over the month before it.  (Hint: LAG + RANK.)

-- Q44. [salary_history] For each department, find the highest hike % ever
--      given and which employee received it.

-- Q45. [salary_history] For each employee, how many years did they wait
--      between joining and their FIRST promotion?

-- Q46. THINKING QUESTION [app_daily_users]: A colleague used
--      LAG(active_users, 7) to compare each day with "the same day last week".
--      Why is that WRONG for this table? Write a correct query.
