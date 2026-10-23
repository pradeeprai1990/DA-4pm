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


-- ---------------------------------------------------------------------
--  SOLUTIONS
-- ---------------------------------------------------------------------

-- Q1
DROP PROCEDURE IF EXISTS show_students;
DELIMITER //
CREATE PROCEDURE show_students()
BEGIN
    SELECT * FROM students;
END //
DELIMITER ;

CALL show_students();


-- Q2  (uses idx_city created above)
DROP PROCEDURE IF EXISTS students_by_city;
DELIMITER //
CREATE PROCEDURE students_by_city(IN p_city VARCHAR(30))
BEGIN
    SELECT * FROM students
    WHERE city = p_city;
END //
DELIMITER ;

CALL students_by_city('Jaipur');


-- Q3  (uses idx_course_city created above)
DROP PROCEDURE IF EXISTS students_by_course;
DELIMITER //
CREATE PROCEDURE students_by_course(IN p_course VARCHAR(30))
BEGIN
    SELECT * FROM students
    WHERE course = p_course
    ORDER BY join_date DESC;
END //
DELIMITER ;

CALL students_by_course('Data Analytics');


-- Q4
DROP PROCEDURE IF EXISTS students_by_fees;
DELIMITER //
CREATE PROCEDURE students_by_fees(IN p_min DECIMAL(10,2), IN p_max DECIMAL(10,2))
BEGIN
    SELECT * FROM students
    WHERE fees BETWEEN p_min AND p_max;
END //
DELIMITER ;

CALL students_by_fees(25000, 30000);


-- Q5
DROP PROCEDURE IF EXISTS total_students;
DELIMITER //
CREATE PROCEDURE total_students(OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM students;
END //
DELIMITER ;

CALL total_students(@total);
SELECT @total AS total_students;


-- Q6  (uses idx_pay_student created above)
DROP PROCEDURE IF EXISTS student_total_paid;
DELIMITER //
CREATE PROCEDURE student_total_paid(IN p_id INT, OUT p_paid DECIMAL(10,2))
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO p_paid
    FROM payments
    WHERE student_id = p_id;
END //
DELIMITER ;

CALL student_total_paid(1, @paid);
SELECT @paid AS total_paid;


-- Q7
DROP PROCEDURE IF EXISTS pending_fees;
DELIMITER //
CREATE PROCEDURE pending_fees()
BEGIN
    SELECT s.name,
           s.fees,
           COALESCE(SUM(p.amount), 0)          AS total_paid,
           s.fees - COALESCE(SUM(p.amount), 0) AS pending
    FROM students s
    LEFT JOIN payments p ON s.student_id = p.student_id
    GROUP BY s.student_id, s.name, s.fees
    ORDER BY pending DESC;
END //
DELIMITER ;

CALL pending_fees();


-- Q8
DROP PROCEDURE IF EXISTS payment_status;
DELIMITER //
CREATE PROCEDURE payment_status(IN p_id INT)
BEGIN
    DECLARE v_fees DECIMAL(10,2);
    DECLARE v_paid DECIMAL(10,2);

    SELECT fees INTO v_fees FROM students WHERE student_id = p_id;
    SELECT COALESCE(SUM(amount), 0) INTO v_paid FROM payments WHERE student_id = p_id;

    IF v_paid >= v_fees THEN
        SELECT p_id AS student_id, 'Fully Paid' AS status;
    ELSEIF v_paid > 0 THEN
        SELECT p_id AS student_id, 'Partially Paid' AS status;
    ELSE
        SELECT p_id AS student_id, 'Not Paid' AS status;
    END IF;
END //
DELIMITER ;

CALL payment_status(1);    -- Fully Paid
CALL payment_status(6);    -- Partially Paid
CALL payment_status(10);   -- Not Paid


-- Q9
DROP PROCEDURE IF EXISTS add_payment;
DELIMITER //
CREATE PROCEDURE add_payment(IN p_id INT, IN p_amount DECIMAL(10,2))
BEGIN
    INSERT INTO payments (student_id, amount, payment_date)
    VALUES (p_id, p_amount, CURDATE());

    SELECT * FROM payments WHERE student_id = p_id;
END //
DELIMITER ;

CALL add_payment(10, 10000);


-- Q10
DROP PROCEDURE IF EXISTS increase_fees;
DELIMITER //
CREATE PROCEDURE increase_fees(IN p_course VARCHAR(30), IN p_percent DECIMAL(5,2))
BEGIN
    UPDATE students
    SET fees = fees + fees * p_percent / 100
    WHERE course = p_course;

    SELECT * FROM students WHERE course = p_course;
END //
DELIMITER ;

CALL increase_fees('Python', 10);


-- ---------------------------------------------------------------------
--  Useful commands
-- ---------------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'sp_db';
SHOW CREATE PROCEDURE payment_status;
-- DROP PROCEDURE IF EXISTS show_students;
