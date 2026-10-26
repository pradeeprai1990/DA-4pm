-- =====================================================================
-- DAY 1 DATASET : employees  (also used on Day 2)
-- Run this file first.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS window_fn_course;
USE window_fn_course;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50),
    department  VARCHAR(30),
    city        VARCHAR(30),
    salary      INT,
    hire_date   DATE
);

INSERT INTO employees (emp_id, emp_name, department, city, salary, hire_date) VALUES
(1,  'Aarav',  'Sales',   'Delhi',     45000, '2020-01-15'),
(2,  'Diya',   'Sales',   'Mumbai',    52000, '2019-03-10'),
(3,  'Rohan',  'Sales',   'Delhi',     38000, '2021-07-01'),
(4,  'Sneha',  'Sales',   'Pune',      52000, '2018-11-20'),
(5,  'Kabir',  'IT',      'Bangalore', 85000, '2017-05-12'),
(6,  'Ananya', 'IT',      'Pune',      72000, '2019-09-23'),
(7,  'Vivaan', 'IT',      'Bangalore', 95000, '2016-02-01'),
(8,  'Isha',   'IT',      'Delhi',     68000, '2022-01-10'),
(9,  'Arjun',  'HR',      'Mumbai',    40000, '2020-06-18'),
(10, 'Meera',  'HR',      'Delhi',     47000, '2018-04-05'),
(11, 'Kunal',  'HR',      'Pune',      40000, '2021-12-01'),
(12, 'Priya',  'Finance', 'Mumbai',    75000, '2017-08-14'),
(13, 'Rahul',  'Finance', 'Delhi',     62000, '2020-10-30'),
(14, 'Tanvi',  'Finance', 'Bangalore', 58000, '2022-03-15'),
(15, 'Neel',   'Finance', 'Mumbai',    62000, '2019-01-25');

SELECT * FROM employees;
