-- =====================================================================
-- DAY 1 : SIMPLE EXAMPLE — start here!
-- A tiny 3-row table to understand OVER() before using real data.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS window_fn_course;
USE window_fn_course;

DROP TABLE IF EXISTS fruit_sales;
CREATE TABLE fruit_sales (
    fruit  VARCHAR(20),
    qty    INT
);

INSERT INTO fruit_sales VALUES
('Apple', 10),
('Banana', 20),
('Mango', 30);


-- STEP 1: Normal aggregate -> the 3 rows become ONE row
SELECT SUM(qty) AS total_qty
FROM fruit_sales;
/*  total_qty
    ---------
    60                 <- only 1 row, fruit names are gone
*/


-- STEP 2: Window function -> all 3 rows stay, total is added to each row
SELECT fruit, qty,
       SUM(qty) OVER () AS total_qty
FROM fruit_sales;
/*  fruit   qty  total_qty
    ------  ---  ---------
    Apple    10         60
    Banana   20         60
    Mango    30         60   <- 3 rows kept!
*/


-- STEP 3: Now we can use the total in a calculation -> % share of each fruit
SELECT fruit, qty,
       SUM(qty) OVER ()                         AS total_qty,
       ROUND(qty * 100.0 / SUM(qty) OVER (), 1) AS pct_share
FROM fruit_sales;
/*  fruit   qty  total_qty  pct_share
    Apple    10         60       16.7
    Banana   20         60       33.3
    Mango    30         60       50.0
*/


-- STEP 4: Other aggregates work the same way
SELECT fruit, qty,
       COUNT(*) OVER () AS total_rows,   -- 3
       AVG(qty) OVER () AS avg_qty,      -- 20.0000
       MAX(qty) OVER () AS max_qty       -- 30
FROM fruit_sales;

-- REMEMBER: OVER() with nothing inside = "look at the whole table".
