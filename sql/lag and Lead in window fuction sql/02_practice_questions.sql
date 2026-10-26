-- =====================================================================
-- LAG & LEAD : PRACTICE QUESTIONS
-- Tables: stock_prices, daily_visits, salary_history, orders, exam_scores
-- Run 01_dataset.sql first. Try every question before opening 03_solutions.sql
-- =====================================================================
USE lag_lead_practice;

-- QUICK REMINDER
--   LAG(col, offset, default)  OVER (PARTITION BY ... ORDER BY ...)  -> value from a PREVIOUS row
--   LEAD(col, offset, default) OVER (PARTITION BY ... ORDER BY ...)  -> value from a NEXT row
--   offset  = how many rows back/forward (default 1)
--   default = value to show when no such row exists (default NULL)


-- ============================ LEVEL 1 : EASY ============================

-- Q1. For each stock, show trade_date, close_price and the previous day's
--     close price (prev_close).

-- Q2. For each stock, show trade_date, close_price and the next day's
--     close price (next_close).

-- Q3. For each stock, show the daily price change
--     (today's close - previous close).

-- Q4. From daily_visits, show each day's visits and the previous row's visits.
--     For the first row show 0 instead of NULL (use the 3rd argument of LAG).

-- Q5. For each stock, show the close price from 2 trading days earlier
--     (price_2_days_ago).


-- ============================ LEVEL 2 : MEDIUM ==========================

-- Q6. For each stock, calculate the daily % change in price, rounded to
--     2 decimals.  Formula: (close - prev_close) * 100 / prev_close

-- Q7. List only the days on which a stock's price went UP compared with the
--     previous day.  (Hint: you cannot use LAG in WHERE -> use a CTE.)

-- Q8. For each stock, add a column 'trend' that shows
--     'Up' / 'Down' / 'Same' compared with the previous day,
--     and 'First Day' for the first row.

-- Q9. From salary_history, show every revision with the previous salary and
--     the hike % (2 decimals). For the first row of each employee
--     show the text 'Joined' in a column called remark.

-- Q10. For each customer, show every order and the number of days since
--      their previous order (days_since_prev).

-- Q11. For each customer, show every order with the next order date and the
--      number of days until the next order. If there is no next order,
--      show 'Last Order' in a column called status.

-- Q12. For each student, show the score change compared with the previous exam.


-- ============================ LEVEL 3 : HARD ============================

-- Q13. daily_visits should have one row for EVERY day, but some dates are
--      missing. Find the gaps: show the date before the gap, the date after
--      the gap and how many days are missing.

-- Q14. Find the stock + date where the price went up 3 days in a row
--      (today > yesterday > day before > day before that).

-- Q15. Find customers whose order amount increased on EVERY order
--      (only customers with more than one order).

-- Q16. Find customers who had a gap of more than 60 days between any two
--      consecutive orders (possible "churn risk" customers).

-- Q17. Find employees who ever got a pay CUT.

-- Q18. Find the biggest single-day gain for each stock (show the stock,
--      date and gain). (Hint: LAG + ROW_NUMBER / RANK.)

-- Q19. Find the students who improved in every exam.

-- Q20. Using LEAD, show the days in daily_visits after which the visits
--      DROPPED on the next available day (show visit_date, visits, next_visits).
