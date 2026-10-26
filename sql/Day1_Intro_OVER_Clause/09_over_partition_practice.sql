-- =====================================================================
-- PRACTICE : OVER() and PARTITION BY ONLY  (table: orders, 100 rows)
-- No ORDER BY inside OVER() and no frames — only OVER() / PARTITION BY.
-- Run 08_large_dataset_examples.sql first (it creates the orders table).
-- Try each question yourself, then check the answer just below it.
--
-- order_amount = quantity * unit_price
-- =====================================================================
USE window_fn_course;


-- ---------------------------------------------------------------------
-- PART A : OVER()  -> the whole table is one window
-- ---------------------------------------------------------------------

-- Q1. Show order_id, customer_name, order_amount and the total sales of
--     the company on every row.
-- ANSWER:
SELECT order_id, customer_name,
       quantity * unit_price                AS order_amount,
       SUM(quantity * unit_price) OVER ()   AS total_sales        -- 2508130
FROM orders;


-- Q2. Show every order with the total number of orders and the average
--     order amount (2 decimals).
-- ANSWER:
SELECT order_id, quantity * unit_price AS order_amount,
       COUNT(*)                             OVER ()   AS total_orders,   -- 100
       ROUND(AVG(quantity * unit_price) OVER (), 2)   AS avg_order       -- 25081.30
FROM orders;


-- Q3. Show each order's amount as a % of total company sales (2 decimals).
-- ANSWER:
SELECT order_id, product,
       quantity * unit_price AS order_amount,
       ROUND(quantity * unit_price * 100.0 / SUM(quantity * unit_price) OVER (), 2) AS pct_of_sales
FROM orders;


-- Q4. Show each order's quantity as a % of total units sold (2 decimals).
-- ANSWER:
SELECT order_id, product, quantity,
       SUM(quantity) OVER ()                                AS total_units,   -- 432
       ROUND(quantity * 100.0 / SUM(quantity) OVER (), 2)   AS pct_of_units
FROM orders;


-- Q5. On every row, show how many orders were paid by Cash.
-- ANSWER:
SELECT order_id, payment_mode,
       SUM(CASE WHEN payment_mode = 'Cash' THEN 1 ELSE 0 END) OVER () AS cash_orders   -- 29
FROM orders;


-- ---------------------------------------------------------------------
-- PART B : PARTITION BY  -> one window per group
-- ---------------------------------------------------------------------

-- Q6. Show every order with the total sales of ITS city.
-- ANSWER:
SELECT order_id, city,
       quantity * unit_price                                    AS order_amount,
       SUM(quantity * unit_price) OVER (PARTITION BY city)      AS city_sales
FROM orders;
-- Delhi = 532500, Pune = 433050, Chennai = 95700 ...


-- Q7. Show every order with the number of orders and total sales of
--     ITS category.
-- ANSWER:
SELECT order_id, category,
       quantity * unit_price                                     AS order_amount,
       COUNT(*)                   OVER (PARTITION BY category)   AS category_orders,
       SUM(quantity * unit_price) OVER (PARTITION BY category)   AS category_sales
FROM orders;
-- Electronics = 25 orders / 1821000,  Books = 20 orders / 56700


-- Q8. Show every order with the average order amount of its category
--     and the difference from that average (2 decimals).
-- ANSWER:
SELECT order_id, category,
       quantity * unit_price                                              AS order_amount,
       ROUND(AVG(quantity * unit_price) OVER (PARTITION BY category), 2)  AS category_avg,
       ROUND(quantity * unit_price
             - AVG(quantity * unit_price) OVER (PARTITION BY category), 2) AS diff_from_cat_avg
FROM orders;
-- Electronics avg = 72840.00,  Grocery avg = 2617.20


-- Q9. Show each order's amount as a % of its CATEGORY's total sales.
-- ANSWER:
SELECT order_id, category, product,
       quantity * unit_price AS order_amount,
       ROUND(quantity * unit_price * 100.0
             / SUM(quantity * unit_price) OVER (PARTITION BY category), 2) AS pct_of_category
FROM orders;


-- Q10. Show every order with the biggest order of its city and the gap
--      from that biggest order.
-- ANSWER:
SELECT order_id, city,
       quantity * unit_price                                    AS order_amount,
       MAX(quantity * unit_price) OVER (PARTITION BY city)      AS city_max,
       MAX(quantity * unit_price) OVER (PARTITION BY city)
           - quantity * unit_price                              AS gap_from_city_max
FROM orders;
-- Chennai max = 24000,  Mumbai max = 60000


-- Q11. Show every order with the customer's total spend and the
--      customer's number of orders.
-- ANSWER:
SELECT order_id, customer_name,
       quantity * unit_price                                          AS order_amount,
       SUM(quantity * unit_price) OVER (PARTITION BY customer_name)   AS customer_total,
       COUNT(*)                   OVER (PARTITION BY customer_name)   AS customer_orders
FROM orders;
-- Priya = 449600 (5 orders),  Isha = 250900 (9 orders)


-- Q12. Show every order with how many orders used the same payment mode.
-- ANSWER:
SELECT order_id, payment_mode,
       COUNT(*) OVER (PARTITION BY payment_mode) AS orders_same_mode
FROM orders;
-- Cash = 29, Net Banking = 26, UPI = 24, Card = 21


-- Q13. Show every order with the total sales of its city AND category
--      together (PARTITION BY two columns).
-- ANSWER:
SELECT order_id, city, category,
       quantity * unit_price                                              AS order_amount,
       SUM(quantity * unit_price) OVER (PARTITION BY city, category)      AS city_cat_sales
FROM orders;
-- There are 36 different (city, category) groups


-- Q14. Show every order with its month and the total sales of that month.
-- ANSWER:
SELECT order_id, order_date,
       MONTH(order_date)                                                AS order_month,
       quantity * unit_price                                            AS order_amount,
       SUM(quantity * unit_price) OVER (PARTITION BY MONTH(order_date)) AS month_sales
FROM orders;
-- Best month: August (8) = 542450,  lowest: January (1) = 44040


-- ---------------------------------------------------------------------
-- PART C : OVER() + PARTITION BY TOGETHER
-- ---------------------------------------------------------------------

-- Q15. Show every order with its city's sales, the company's sales, and
--      the city's share of company sales (%).
-- ANSWER:
SELECT order_id, city,
       SUM(quantity * unit_price) OVER (PARTITION BY city)  AS city_sales,
       SUM(quantity * unit_price) OVER ()                   AS company_sales,
       ROUND(SUM(quantity * unit_price) OVER (PARTITION BY city) * 100.0
             / SUM(quantity * unit_price) OVER (), 2)       AS city_pct
FROM orders;
-- Delhi = 21.23%,  Chennai = 3.82%


-- Q16. Show every order with the company average and its category
--      average side by side.
-- ANSWER:
SELECT order_id, category,
       quantity * unit_price                                              AS order_amount,
       ROUND(AVG(quantity * unit_price) OVER (), 2)                       AS company_avg,
       ROUND(AVG(quantity * unit_price) OVER (PARTITION BY category), 2)  AS category_avg
FROM orders;


-- Q17. Label each order 'Above Category Avg' or 'Below Category Avg'.
-- ANSWER:
SELECT order_id, category,
       quantity * unit_price AS order_amount,
       CASE
           WHEN quantity * unit_price > AVG(quantity * unit_price) OVER (PARTITION BY category)
                THEN 'Above Category Avg'
           ELSE 'Below Category Avg'
       END AS order_label
FROM orders;
-- 32 orders are 'Above Category Avg'


-- ---------------------------------------------------------------------
-- PART D : FILTER ON A WINDOW RESULT  (use a subquery)
-- ---------------------------------------------------------------------

-- Q18. Show only the BIGGEST order(s) of each city.
-- ANSWER:
SELECT order_id, city, order_amount
FROM (
    SELECT order_id, city,
           quantity * unit_price                               AS order_amount,
           MAX(quantity * unit_price) OVER (PARTITION BY city) AS city_max
    FROM orders
) AS t
WHERE order_amount = city_max;
-- 9 rows: 8 cities, Delhi has 2 orders tied at 165000


-- Q19. Show the customers (one row each) whose total spend is more
--      than 1,00,000.
-- ANSWER:
SELECT DISTINCT customer_name, customer_total
FROM (
    SELECT customer_name,
           SUM(quantity * unit_price) OVER (PARTITION BY customer_name) AS customer_total
    FROM orders
) AS t
WHERE customer_total > 100000
ORDER BY customer_total DESC;
-- 9 customers: Priya, Isha, Arjun, Pooja, Riya, Aditya, Karan, Aarav, Kunal


-- Q20. Show the orders that are more than 30% of their city's total sales.
-- ANSWER:
SELECT order_id, city, order_amount, pct_of_city
FROM (
    SELECT order_id, city,
           quantity * unit_price AS order_amount,
           ROUND(quantity * unit_price * 100.0
                 / SUM(quantity * unit_price) OVER (PARTITION BY city), 2) AS pct_of_city
    FROM orders
) AS t
WHERE pct_of_city > 30;
-- 8 rows (Bangalore #73 is the highest at 47.12%)


-- Q21. GROUP BY vs PARTITION BY: write both queries for total sales per
--      city. How many rows does each return? Why?
-- ANSWER:
SELECT city, SUM(quantity * unit_price) AS city_sales
FROM orders
GROUP BY city;                                                  -- 8 rows

SELECT order_id, city,
       SUM(quantity * unit_price) OVER (PARTITION BY city) AS city_sales
FROM orders;                                                    -- 100 rows
-- GROUP BY collapses each city into ONE row.
-- PARTITION BY keeps all 100 rows and repeats the city total on each row.
