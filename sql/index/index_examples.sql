-- =====================================================================
--  INDEXES IN MYSQL - 10 EXAMPLES (for Data Analyst students)
-- =====================================================================
--  What is an Index?
--  An index is like the INDEX page at the back of a book. Without it,
--  MySQL reads EVERY row to find a match (Full Table Scan). With an
--  index, MySQL jumps straight to the matching rows -> faster SELECT.
--
--  Without index -> type = ALL  (scans all rows)
--  With index    -> type = ref / range / const (uses the index)
--
--  Syntax:
--      CREATE INDEX index_name ON table_name (column1, column2, ...);
--      CREATE UNIQUE INDEX index_name ON table_name (column);
--      DROP INDEX index_name ON table_name;
--      SHOW INDEX FROM table_name;
--
--  Types of indexes:
--      Primary Key  -> created automatically on PRIMARY KEY column
--      Unique       -> no duplicate values allowed
--      Single       -> index on one column
--      Composite    -> index on two or more columns
--
--  Advantages    : Faster SELECT, WHERE, JOIN, ORDER BY
--  Disadvantages : Takes extra space, makes INSERT/UPDATE/DELETE slower
--  So, create index only on columns you SEARCH / FILTER / JOIN on often.
-- =====================================================================


-- =====================================================================
--  STEP 1 : DATASET
-- =====================================================================
DROP DATABASE IF EXISTS index_db;
CREATE DATABASE index_db;
USE index_db;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(50),
    email      VARCHAR(100),
    city       VARCHAR(30),
    course     VARCHAR(30),
    fees       DECIMAL(10,2),
    join_date  DATE
);

CREATE TABLE payments (
    payment_id   INT PRIMARY KEY AUTO_INCREMENT,
    student_id   INT,
    amount       DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

INSERT INTO students (name, email, city, course, fees, join_date) VALUES
('Rahul',  'rahul@gmail.com',  'Jaipur', 'Data Analytics', 40000, '2026-01-10'),
('Meera',  'meera@gmail.com',  'Delhi',  'Python',         25000, '2026-02-15'),
('Arjun',  'arjun@gmail.com',  'Jaipur', 'Data Analytics', 40000, '2026-03-01'),
('Neha',   'neha@gmail.com',   'Mumbai', 'Web Dev',        30000, '2026-03-20'),
('Suresh', 'suresh@gmail.com', 'Delhi',  'Data Analytics', 40000, '2026-04-05'),
('Kavita', 'kavita@gmail.com', 'Jaipur', 'Python',         25000, '2026-04-18'),
('Amit',   'amit@gmail.com',   'Pune',   'Web Dev',        30000, '2026-05-02'),
('Pooja',  'pooja@gmail.com',  'Mumbai', 'Data Analytics', 40000, '2026-05-25'),
('Vikas',  'vikas@gmail.com',  'Delhi',  'Python',         25000, '2026-06-10'),
('Sneha',  'sneha@gmail.com',  'Pune',   'Web Dev',        30000, '2026-07-01');

INSERT INTO payments (student_id, amount, payment_date) VALUES
(1, 20000, '2026-01-10'), (1, 20000, '2026-02-10'),
(2, 25000, '2026-02-15'),
(3, 15000, '2026-03-01'), (3, 15000, '2026-04-01'),
(4, 30000, '2026-03-20'),
(5, 40000, '2026-04-05'),
(6, 10000, '2026-04-18'),
(7, 15000, '2026-05-02'),
(8, 20000, '2026-05-25'), (8, 20000, '2026-06-25'),
(9, 25000, '2026-06-10');
-- Sneha (10) has paid nothing yet


-- =====================================================================
--  STEP 2 : INDEX EXAMPLES
-- =====================================================================

-- Example 1 : See existing indexes (PRIMARY KEY index already exists)
SHOW INDEX FROM students;


-- Example 2 : Query WITHOUT index -> check with EXPLAIN
--             Look at column "type" = ALL  (full table scan)
EXPLAIN SELECT * FROM students WHERE city = 'Jaipur';


-- Example 3 : Single column index
CREATE INDEX idx_city ON students (city);

--             Same query again -> now "type" = ref, "key" = idx_city
EXPLAIN SELECT * FROM students WHERE city = 'Jaipur';


-- Example 4 : Unique index (no two students can have same email)
CREATE UNIQUE INDEX idx_email ON students (email);

-- This will give ERROR : Duplicate entry 'rahul@gmail.com'
-- INSERT INTO students (name, email) VALUES ('Rahul2', 'rahul@gmail.com');


-- Example 5 : Composite index (two columns together)
CREATE INDEX idx_course_city ON students (course, city);

--             Uses the index (leftmost column "course" is in WHERE)
EXPLAIN SELECT * FROM students WHERE course = 'Python' AND city = 'Delhi';
EXPLAIN SELECT * FROM students WHERE course = 'Python';

--             Does NOT use idx_course_city (leftmost column missing)
--             (it may use idx_city instead)
EXPLAIN SELECT * FROM students WHERE city = 'Delhi';


-- Example 6 : Index on a column used in JOIN
CREATE INDEX idx_pay_student ON payments (student_id);

EXPLAIN
SELECT s.name, p.amount
FROM students s
JOIN payments p ON s.student_id = p.student_id;


-- Example 7 : Index for range search / ORDER BY
CREATE INDEX idx_join_date ON students (join_date);

EXPLAIN SELECT * FROM students
WHERE join_date BETWEEN '2026-03-01' AND '2026-05-31'
ORDER BY join_date;


-- Example 8 : Index is NOT used when you apply a function on the column
EXPLAIN SELECT * FROM students WHERE YEAR(join_date) = 2026;      -- no index
EXPLAIN SELECT * FROM students
WHERE join_date >= '2026-01-01' AND join_date < '2027-01-01';     -- uses index


-- Example 9 : Index is NOT used for LIKE starting with %
EXPLAIN SELECT * FROM students WHERE city LIKE 'Ja%';   -- uses idx_city
EXPLAIN SELECT * FROM students WHERE city LIKE '%ur';   -- no index


-- Example 10 : Drop an index
DROP INDEX idx_join_date ON students;
SHOW INDEX FROM students;

