-- Set the search path to dsps schema
SET search_path TO dsps;

-- Insert a student with Student number: 600; Name= ‘Peterson, J’; email= ‘PeteJ@myhome.com’
INSERT INTO student 
VALUES (600, 'Peterson, J', 'PeteJ@myhome.com');

-- Insert a exam with values:   Exam code : ‘VB03’; Exam title : ‘Visual Basic 3’; Exam location : ‘London’; 
-- Exam date : 2022-06-03 Exam time : 09:00
INSERT INTO exam 
VALUES ('VB03', 'Visual Basic 3', 'London', '2022-06-03', '09:00');

-- Insert an entry with values:  Exam code : ‘VB03’ Exam title : Student number : ‘100’
-- The reference number (eno) = the latest reference number + 1
INSERT INTO entry(eno, excode, sno)
VALUES ((SELECT COALESCE(MAX(eno),0) FROM entry) + 1, 'VB03', 100);

-- Update an entry with Entry number: ‘10’,  for ‘VB03’ and student number ‘100, 
UPDATE entry 
SET egrade = 60
WHERE eno = 10;

-- Student Examination Timetables: Produce a table showing the examination timetable for a given student. 
-- Produce timetable for student number: 100
SELECT en.sno AS membership_number, s.sname AS student_name, 
ex.exlocation AS exam_location, en.excode AS exam_code, ex.extitle AS exam_title, 
ex.exdate AS exam_date, ex.extime AS exam_time
FROM entry AS en, student AS s, exam AS ex
WHERE en.sno = s.sno AND en.excode = ex.excode AND en.sno = 100
ORDER BY exam_date,exam_time ASC


-- All examination results: Produce a table showing the result obtained by each student for each examination.
-- Categorize the results into: "Not taken", "Fail", "Pass", "Distinction"
CREATE VIEW all_exam_grade AS
SELECT 
en.excode AS exam_code, 
s.sname AS student_name,
CASE
	WHEN en.egrade ISNULL
		THEN 'Not taken'
	WHEN en.egrade < 50 
		THEN 'Fail'
    WHEN en.egrade >= 50 AND en.egrade < 70 
		THEN 'Pass'
    WHEN en.egrade >= 70 
		THEN 'Distinction'
END exam_grade
FROM entry AS en, student AS s
WHERE en.sno = s.sno
ORDER BY exam_code, student_name;

SELECT * FROM all_exam_grade;


-- Results for selected student: Produce a table showing details of all examinations taken by a student. 
-- Select results for student number: ‘100’
CREATE VIEW numeric_grade AS
SELECT 
en.sno AS membership_number, s.sname AS membership_name, 
en.excode AS exam_code, ex.extitle AS exam_title, 
en.egrade AS exam_numeric_grade
FROM entry AS en, student AS s, exam AS ex
WHERE en.sno = s.sno AND en.excode = ex.excode
ORDER BY exam_code ASC;

SELECT * FROM numeric_grade WHERE membership_number = 100;

-- Membership status for selected student: Given a specific student membership number, 
-- display the name of the student and their membership status in the society.
-- Display membership status for student number: ‘100’
CREATE or REPLACE FUNCTION membership_status(integer)
RETURNS text AS $BODY$ 
	BEGIN	
	IF (SELECT COUNT(exam_numeric_grade) FROM numeric_grade WHERE membership_number = $1) >= 4
		AND (SELECT AVG(exam_numeric_grade) FROM numeric_grade WHERE membership_number = $1) >= 50
	THEN 
	RETURN 'Accredited';
	ELSE
	RETURN 'Pending';
	END IF;
	END; 
	$BODY$ LANGUAGE plpgsql;

SELECT DISTINCT membership_number, membership_name, membership_status(100) 
FROM numeric_grade 
WHERE membership_number = 100

-- Delete selected student: This happens if a student withdraws from the society.  
-- All the examination entries for the student must be cancelled. 
-- Delete student number: ‘200’
DELETE FROM student WHERE sno = 200;

-- Delete selected examination: 
-- Delete exam code : ‘SQL1’
DELETE FROM exam WHERE excode = 'SQL1'

-- Show the cancel table
SELECT * FROM cancel ORDER BY eno;
