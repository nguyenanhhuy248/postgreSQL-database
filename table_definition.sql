-- Create schema
CREATE SCHEMA dsps;

-- Set the search path to dsps schema
SET search_path TO dsps;

-- Create 4 tables with conditions on some column inputs:
-- Create exam table:
CREATE TABLE exam (
    excode       CHAR(4) PRIMARY KEY,
    extitle      VARCHAR(20) NOT NULL,
    exlocation   VARCHAR(20) NOT NULL,
    exdate       DATE NOT NULL
		CHECK (exdate >= '2022-06-01' AND exdate <= '2022-06-30'),
    extime       TIME NOT NULL
		CHECK (extime >= '09:00:00' AND extime <= '18:00:00'));
CREATE INDEX idx_exam ON exam(excode);

-- Create student table:
CREATE TABLE student (
    sno          INTEGER PRIMARY KEY,
    sname        VARCHAR(20) NOT NULL,
    semail       VARCHAR(20) NOT NULL);
CREATE INDEX idx_student ON student(sno);

-- Create entry table:
CREATE TABLE entry (
    eno          INTEGER PRIMARY KEY,
    excode       CHAR(4) NOT NULL,
    sno          INTEGER NOT NULL,
    egrade       DECIMAL(5,2)
		CHECK (egrade >= 0 AND egrade <= 100),
    UNIQUE (excode, sno), -- As a student can only enter a specific examination once in a year
	FOREIGN KEY (excode) REFERENCES exam 
 		ON DELETE RESTRICT
		ON UPDATE RESTRICT, 
	FOREIGN KEY (sno) REFERENCES student 
 		ON DELETE CASCADE
    		ON UPDATE RESTRICT);

-- Create cancel table:	
CREATE TABLE cancel (
    eno          INTEGER,
    excode       CHAR(4) NOT NULL,
    sno          INTEGER NOT NULL,
    cdate        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cuser        VARCHAR(128) DEFAULT current_user,
CONSTRAINT cancel_pk PRIMARY KEY (eno, cdate));
CREATE INDEX idx_cancel ON cancel(eno);


-- Create rigger to insert deleted entry into cancel table 
CREATE OR REPLACE FUNCTION update_cancel_table() 
RETURNS trigger AS $BODY$ 
BEGIN 
INSERT INTO
        cancel (eno,excode,sno)
        VALUES (OLD.eno,OLD.excode,OLD.sno);

RETURN OLD; 
END; $BODY$ 
LANGUAGE plpgsql; 

CREATE TRIGGER cancel_entry BEFORE DELETE ON entry
FOR EACH ROW
EXECUTE PROCEDURE update_cancel_table();


-- Create trigger to check insert on entry
CREATE or REPLACE FUNCTION entry_insert_check()
RETURNS trigger AS $BODY$
BEGIN
	IF 
	(NEW.excode 
	IN 
	(SELECT DISTINCT excode FROM entry AS en WHERE en.sno = NEW.sno))
	THEN
 	RAISE EXCEPTION 'A student can only enter a specific examination once in a year!'; 
	ELSEIF 
	(SELECT exdate FROM exam AS ex WHERE ex.excode = NEW.excode)
	IN 
	(SELECT DISTINCT exdate FROM exam AS ex, entry AS en 
	WHERE ex.excode = en.excode AND sno = NEW.sno)
	THEN
    	RAISE EXCEPTION 'A student cannot take two examinations on the same day!'; 
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE TRIGGER entry_insert BEFORE INSERT ON entry 
FOR EACH ROW EXECUTE PROCEDURE entry_insert_check();