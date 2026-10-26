-- =====================================================================
-- LAG & LEAD PRACTICE : DATASET
-- Requirement: MySQL 8.0+  (window functions are not in MySQL 5.7)
-- Run this file first, then open 02_practice_questions.sql
-- =====================================================================

CREATE DATABASE IF NOT EXISTS lag_lead_practice;
USE lag_lead_practice;

DROP TABLE IF EXISTS stock_prices;
DROP TABLE IF EXISTS daily_visits;
DROP TABLE IF EXISTS salary_history;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS exam_scores;

-- ---------------------------------------------------------------------
-- 1) stock_prices : closing price of 2 stocks on trading days
-- ---------------------------------------------------------------------
CREATE TABLE stock_prices (
    stock_symbol VARCHAR(10),
    trade_date   DATE,
    close_price  DECIMAL(10,2)
);

INSERT INTO stock_prices VALUES
('INFY', '2024-01-01', 1500), ('INFY', '2024-01-02', 1520),
('INFY', '2024-01-03', 1510), ('INFY', '2024-01-04', 1510),
('INFY', '2024-01-05', 1545), ('INFY', '2024-01-08', 1560),
('TCS',  '2024-01-01', 3600), ('TCS',  '2024-01-02', 3580),
('TCS',  '2024-01-03', 3620), ('TCS',  '2024-01-04', 3650),
('TCS',  '2024-01-05', 3700), ('TCS',  '2024-01-08', 3690);

-- ---------------------------------------------------------------------
-- 2) daily_visits : website visits per day (some dates are MISSING)
-- ---------------------------------------------------------------------
CREATE TABLE daily_visits (
    visit_date DATE,
    visits     INT
);

INSERT INTO daily_visits VALUES
('2024-03-01', 120), ('2024-03-02', 135), ('2024-03-03', 150),
('2024-03-04', 140), ('2024-03-06', 160), ('2024-03-07', 175),
('2024-03-09', 190), ('2024-03-10', 170);

-- ---------------------------------------------------------------------
-- 3) salary_history : every salary revision of an employee
-- ---------------------------------------------------------------------
CREATE TABLE salary_history (
    emp_id      INT,
    emp_name    VARCHAR(50),
    change_date DATE,
    salary      INT
);

INSERT INTO salary_history VALUES
(101, 'Amit', '2021-04-01', 30000), (101, 'Amit', '2022-04-01', 33000),
(101, 'Amit', '2023-04-01', 36300),
(102, 'Neha', '2021-06-15', 45000), (102, 'Neha', '2022-06-15', 45000),
(102, 'Neha', '2023-06-15', 50000),
(103, 'Ravi', '2022-01-10', 28000), (103, 'Ravi', '2023-01-10', 26000),
(103, 'Ravi', '2024-01-10', 30000);

-- ---------------------------------------------------------------------
-- 4) orders : customer orders
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    order_id    INT,
    customer_id VARCHAR(10),
    order_date  DATE,
    amount      INT
);

INSERT INTO orders VALUES
(1, 'C1', '2024-01-05',  500), (2, 'C1', '2024-01-20',  700),
(3, 'C1', '2024-03-15',  650),
(4, 'C2', '2024-02-01', 1200), (5, 'C2', '2024-02-10', 1500),
(6, 'C2', '2024-02-25', 1800),
(7, 'C3', '2024-01-10',  300), (8, 'C3', '2024-05-20',  400),
(9, 'C4', '2024-04-01',  900);

-- ---------------------------------------------------------------------
-- 5) exam_scores : 4 exams per student
-- ---------------------------------------------------------------------
CREATE TABLE exam_scores (
    student VARCHAR(50),
    exam_no INT,
    score   INT
);

INSERT INTO exam_scores VALUES
('Riya',  1, 65), ('Riya',  2, 72), ('Riya',  3, 70), ('Riya',  4, 85),
('Karan', 1, 80), ('Karan', 2, 78), ('Karan', 3, 82), ('Karan', 4, 90),
('Meena', 1, 55), ('Meena', 2, 60), ('Meena', 3, 68), ('Meena', 4, 75);
