
CREATE DATABASE  Education_StudentDb1;

USE Education_StudentDb1;


CREATE TABLE Student(
      [StudentID] NVARCHAR(20), 
	  [StudentName] NVARCHAR(30), 
	  [Age] INT,
	  [ClassID]INT,
	  [StateID] INT,
	  );


INSERT INTO Student(StudentID,	StudentName,	Age,	ClassID,	StateID)
VALUES   
     ('S01','Alice Brown', '16', '1', '101'),
     ('S02', 'Bob White','15','2', '102'), 
     ('S03', 'Charlie Black', '17','3', '103'),
     ('S04', 'Daisy Green', '16','4', '104'),
     ('S05', 'Edward Blue', '14','1', '105'),
     ('S06', 'Fiona Red', '18','2', '106'),
	 ('S07', 'George Yellow', '15','3', '107'),
     ('S08', 'Hannah Purple', '16','4', '108'),
	 ('S09', 'Ian Orange', '17','1', '109'),
	 ('S10', 'Jane Grey', '14','2', '110');




CREATE TABLE ClassMaster
(
     [ClassID] INT,
	  [ClassName] NVARCHAR(20),
	  [TeacherID] NVARCHAR(30)
	  );


INSERT INTO ClassMaster (ClassID, ClassName,TeacherID)
VALUES  
	('1', '10th Grade', 'T01'),
	('2', '9th Grade', 'T02'),
	('3', '11th Grade','T03'),
	('4', '12th Grade', 'T04');



CREATE TABLE  TeacherMaster
(
       [TeacherID] NVARCHAR(20),
	   [TeacherName] NVARCHAR(30),
	   [Subject] NVARCHAR(20)
	  );


INSERT INTO TeacherMaster(TeacherID,TeacherName,Subject)
VALUES
    ('T01',	'Mr. Johnson','Mathematics'),
	('T02',	'Ms. Smith','Science'),
	('T03',	'Mr. Williams',	'English'),
	('T04',	'Ms. Brown','History');


CREATE TABLE StateMaster
(
	 [StateID] INT,
	 [StateName] NVARCHAR(20)
	 );


INSERT INTO StateMaster(StateID, StateName)
VALUES  
	('101', 'Lagos'),
	('102', 'Abuja'),
	('103', 'Kano'),
	('104', 'Delta'),
	('105','Ido'),
	('106','Ibadan'),
	('107','Enugu'),
	('108','Kaduna'),
	('109','Ogun'),
	('110','Anambra');

	

----------------------------1.Fetch students with the same age.


SELECT * 
FROM Student
WHERE Age IN (
   SELECT Age
   FROM Student
   GROUP BY Age
   HAVING COUNT (Age) > 1
);
select*from Student



-----------------------2.Find the second youngest student and their class and teacher.


SELECT S.StudentID, S.StudentName,S.Age,C.ClassName, T.TeacherName
FROM Student S
INNER JOIN Classmaster C
ON S.ClassID = C.ClassID
INNER JOIN Teachermaster T
ON C.TeacherID = T.TeacherID
ORDER BY Age 
OFFSET  1 ROW
FETCH NEXT 1 ROW ONLY


---------------3.	Get the maximum age per class and the student name.


SELECT  S.StudentName, S.Age MAXAge, C.ClassName, T.TeacherName
FROM Student S
INNER JOIN Classmaster C
ON S.ClassID = C.ClassID
INNER JOIN Teachermaster T
ON C.TeacherID = T.TeacherID
JOIN (SELECT ClassID, MAX (Age) AS MAXAge
FROM Student S
GROUP BY ClassID) M ON S.ClassID = M.ClassID
AND S.Age = M.MAXAge



------------------4.	Teacher-wise count of students sorted by count in descending order.


SELECT COUNT(DISTINCT S.StudentName) count_of_tw, T.TeacherName
 FROM Student S, TeacherMaster T, ClassMaster C
 WHERE C.TeacherID = T.TeacherID
 AND S.ClassID = C.ClassID
 GROUP BY S.StudentName, T.TeacherName
 ORDER BY COUNT(*) DESC


-----------------5.	Fetch only the first name from the StudentName and append the age.

SELECT CONCAT(LEFT(StudentName,
        CHARINDEX (' ',StudentName )-1), '_',Age) FirstName_Age
FROM Student S


-------------------6.	Fetch students with odd ages.

SELECT StudentName,Age  FROM Student S
WHERE Age % 2 = 1


----------------7.	Create a view to fetch student details with an age greater than 15.


CREATE VIEW vw_pt_age_15 
AS
 SELECT S.StudentID, S.StudentName,S.Age, C.ClassName, T.TeacherName, T.Subject, ST.StateName
 FROM Student S
 INNER JOIN Classmaster C
ON S.ClassID = C.ClassID
INNER JOIN Teachermaster T
ON C.TeacherID = T.TeacherID
INNER JOIN Statemaster ST 
 ON S.StateID = ST.StateID
 WHERE S.Age > 15

---------------8.Create a procedure to update the student's age by 1 year where the class is '10th Grade' and the teacher is not 'Mr. Johnson'.


CREATE PROCEDURE IncreaseAge
AS
 BEGIN 
	UPDATE S
	SET S.Age = S.Age + 1
	FROM Student S
	INNER JOIN ClassMaster C ON S.ClassID = C.ClassID
    INNER JOIN TeacherMaster T ON C.TeacherID = T.TeacherID
	WHERE C.ClassName = '10th Grade' 
	AND T.TeacherName NOT IN ('Mr. Johnson');
END;
GO;
EXEC increaseAge;
GO 


---------------------9.Create a stored procedure to fetch loan details along with the customer, branch, and state, including error handling.


CREATE PROCEDURE sp_fetch_loan_details
AS
BEGIN
    BEGIN TRY
        SELECT  
		 S.StudentID,
		 S.StudentName,
		 S.Age, 
		 C.ClassName, 
		 T.TeacherName, 
		 T.Subject, 
		 ST.StateName
        FROM Student S
  INNER JOIN Classmaster C ON S.ClassID = C.ClassID
  INNER JOIN Teachermaster T ON C.TeacherID = T.TeacherID
  INNER JOIN Statemaster ST ON S.StateID = ST.StateID
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(3000)
		SET @ErrorMessage = ERROR_MESSAGE()
        RAISERROR (@ErrorMessage, 20,1);
    END CATCH
END;
GO
