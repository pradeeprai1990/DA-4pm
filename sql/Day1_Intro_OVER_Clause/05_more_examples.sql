-- =====================================================================
-- DAY 1 : MORE EXAMPLES  (the same examples as the "Example" slides)
-- Each example creates its own tiny table, runs the query, and shows the
-- expected output in a comment. Run them one by one.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS window_fn_course;
USE window_fn_course;


-- ---------------------------------------------------------------------
-- EXAMPLE 1 : SHARE OF TOTAL
-- What % of the team's runs did each batter score?
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS batting;
CREATE TABLE batting (player VARCHAR(20), runs INT);
INSERT INTO batting VALUES ('Rohit', 60), ('Virat', 90), ('Gill', 30), ('Rahul', 20);

SELECT player, runs,
       SUM(runs) OVER ()                          AS team_total,
       ROUND(runs * 100.0 / SUM(runs) OVER (), 1) AS pct
FROM batting;
/*  Expected output:
    player  runs  team_total  pct
    ------  ----  ----------  ----
    Rohit   60    200         30.0
    Virat   90    200         45.0
    Gill    30    200         15.0
    Rahul   20    200         10.0
*/


-- ---------------------------------------------------------------------
-- EXAMPLE 2 : ABOVE OR BELOW AVG
-- Which cities are hotter or colder than the average?
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS city_temp;
CREATE TABLE city_temp (city VARCHAR(20), temp INT);
INSERT INTO city_temp VALUES ('Delhi', 40), ('Mumbai', 32), ('Shimla', 18), ('Chennai', 34);

SELECT city, temp,
       ROUND(AVG(temp) OVER (), 1)        AS avg_temp,
       ROUND(temp - AVG(temp) OVER (), 1) AS diff
FROM city_temp;
/*  Expected output:
    city     temp  avg_temp  diff
    -------  ----  --------  -----
    Delhi    40    31.0      9.0
    Mumbai   32    31.0      1.0
    Shimla   18    31.0      -13.0
    Chennai  34    31.0      3.0
*/


-- ---------------------------------------------------------------------
-- EXAMPLE 3 : COUNT, MAX & GAP
-- How many students, what is the top score, and how far is each from the top?
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS test_scores;
CREATE TABLE test_scores (student VARCHAR(20), score INT);
INSERT INTO test_scores VALUES ('Anu', 72), ('Ben', 95), ('Cara', 58), ('Dev', 81);

SELECT student, score,
       COUNT(*)   OVER ()         AS students,
       MAX(score) OVER ()         AS top_score,
       MAX(score) OVER () - score AS gap
FROM test_scores;
/*  Expected output:
    student  score  students  top_score  gap
    -------  -----  --------  ---------  ---
    Anu      72     4         95         23
    Ben      95     4         95         0
    Cara     58     4         95         37
    Dev      81     4         95         14
*/
