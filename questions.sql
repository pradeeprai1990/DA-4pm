-- =====================================================================
--  STORED PROCEDURE - 10 QUESTIONS  (Dataset : sp_db)
--  This file is complete on its own - run it from top to bottom.
-- =====================================================================


-- =====================================================================
--  STEP 1 : DATASET
-- =====================================================================
DROP DATABASE IF EXISTS sp_db;
CREATE DATABASE sp_db;
USE sp_db;

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

-- Indexes on columns the procedures search on
CREATE INDEX idx_city        ON students (city);
CREATE INDEX idx_course_city ON students (course, city);
CREATE INDEX idx_pay_student ON payments (student_id);


-- =====================================================================
--  STEP 2 : QUESTIONS
-- =====================================================================
-- Q1.  Create a procedure that shows all students.
-- Q2.  Create a procedure that takes a city and shows students of that city.
-- Q3.  Create a procedure that takes a course and shows its students,
--      newest joined first.
-- Q4.  Create a procedure that takes a minimum and maximum fees and shows
--      students whose fees are between them.
-- Q5.  Create a procedure that returns (OUT) the total number of students.
-- Q6.  Create a procedure that takes a student_id and returns (OUT) the
--      total amount paid by that student.
-- Q7.  Create a procedure that shows each student's name, fees, total paid
--      and pending amount (fees - paid).
-- Q8.  Create a procedure that takes a student_id and shows
--      'Fully Paid' if paid >= fees, 'Partially Paid' if paid > 0,
--      otherwise 'Not Paid'.
-- Q9.  Create a procedure that adds a new payment
--      (student_id, amount) with today's date.
-- Q10. Create a procedure that takes a course and a percentage and
--      increases the fees of that course by that percentage.