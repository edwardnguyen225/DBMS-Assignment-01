-- DROP VIEW LECTURER_INFO
CREATE VIEW LECTURER_INFO AS
SELECT LID,
       LName,
       FName,
       Gender,
       DOB,
       Email,
       FEName
FROM MemberOfEducationUnit,
     Employee,
     Lecturer
WHERE ID = PersonalEID
  AND EmployeeID = LID;

CREATE VIEW STUDENT_INFO AS
SELECT Studentid,
       Lname,
       Fname,
       Gender,
       Dob,
       Email
FROM MemberOfEducationUnit,
     Student
WHERE ID = PersonalSID;

DROP VIEW IF EXISTS SUBCLASS_INFO;
CREATE VIEW SUBCLASS_INFO AS
SELECT CID,
       CYear,
       CSemester,
       SID,
       CName,
       SCLID
FROM SubClass,
     Subject
WHERE SCID = CID;

DROP VIEW IF EXISTS LECTURERS_SUBJECT;
CREATE VIEW LECTURERS_SUBJECT AS
SELECT DISTINCT LID, FEName, CNAME, CID, CSemester
FROM LECTURER_INFO, SUBCLASS_INFO
WHERE SCLID = LID;


-- (iii.1). Cập nhật giáo trình chính cho môn học do mình phụ trách.

INSERT INTO MainlyUse(MCID, MISBD)
VALUES ('','1234567');

-- Xem các textbook theo môn học của khoa của gv
SELECT *
FROM MainlyUse
WHERE MCID IN
    (SELECT CID
     FROM Subject,
          Faculty
     WHERE FCName = FacultyName
       AND FacultyName IN
         (SELECT FEName
          FROM LECTURER_INFO
          WHERE EmployeeID ='000002'));


UPDATE MainlyUse(MCID, MISBD)
SET MISBD = ''
WHERE MISBD = '';

-- xóa textbook chính theo mã môn học
DELETE
FROM MainlyUse
WHERE MCID = '';

-- xóa textbook chính
DELETE
FROM MainlyUse
WHERE MISBD = '';

-- (iii.2). Xem danh sách lớp học của mỗi môn học do mình phụ trách ở một học kỳ.
-- danh sách Class
SELECT CID, CName
FROM Class, LECTURERS_SUBJECT
WHERE LID = '000002' AND CSemester = '201' AND CCID = CID;

-- danh sách SubClass
SELECT *
FROM SUBCLASS_INFO
WHERE CID IN (SELECT CID
               FROM Class, LECTURERS_SUBJECT
               WHERE LID = '000002' AND CSemester = '201' AND CCID = CID;
               );

-- (iii.3). Xem danh sách sinh viên của mỗi lớp học do mình phụ trách ở một học kỳ.
-- theo Class
SELECT ACID AS CID, StudentID, LName, FName FROM STUDENT_INFO, Attend
WHERE AStudentID = StudentID
   AND ACID IN (SELECT CCID
               FROM Class, LECTURERS_SUBJECT
               WHERE LID = '000002' AND CSemester = '201' AND CCID = CID)
ORDER BY ACID;

-- theo SubClass
SELECT ASID AS SID, StudentID, LName, FName FROM STUDENT_INFO, Attend
WHERE AStudentID = StudentID
   AND ASID IN (SELECT SID
               FROM SUBCLASS_INFO
               WHERE CID IN (SELECT CCID
                              FROM Class, LECTURERS_SUBJECT
                              WHERE LID = '000002' AND CSemester = '201'  AND CCID = CID)
               )
ORDER BY ASID;


-- (iii.4). Xem danh sách môn học và giáo trình chính cho mỗi môn học do mình phụ
-- trách ở một học kỳ.
SELECT CID, CName, TName, ISBN
FROM LECTURERS_SUBJECT, Textbook, MainlyUse
WHERE LID = '000002'
   AND CSemester = '201'
   AND ISBN = MISBD
   AND MCID = CID
ORDER BY CID;


-- (iii.5). Xem tổng số sinh viên của mỗi lớp học do mình phụ trách ở một học kỳ.
-- theo Class
SELECT ACID AS CID, COUNT(AStudentID) AS STUDENT_NUM
FROM Attend
WHERE ACID IN (SELECT CCID
               FROM Class, LECTURERS_SUBJECT
               WHERE LID = '000002' AND CSemester = '201' AND CCID = CID)
GROUP BY ACID;

--  theo SubClass
SELECT ASID AS SID,COUNT(AStudentID) AS STUDENT_NUM
FROM Attend
WHERE ASID IN (SELECT SID
               FROM SUBCLASS_INFO
               WHERE CID IN (SELECT CCID
                              FROM Class, LECTURERS_SUBJECT
                              WHERE LID = '000002' AND CSemester = '201' AND CCID = CID))
GROUP BY ASID;

-- (iii.6). Xem số lớp học do mình phụ trách ở mỗi học kỳ trong 3 năm liên tiếp gần đây nhất.
-- theo Class
SELECT CSemester, COUNT(DISTINCT CID) AS CLASS_NUM
FROM SUBCLASS_INFO
WHERE CYear BETWEEN (YEAR(CURDATE()) - 3) AND (YEAR(CURDATE()))
      AND SCLID = '000002'
GROUP BY CSemester;


-- theo SubClass
SELECT CSemester, COUNT(SID) AS CLASS_NUM
FROM SUBCLASS_INFO
WHERE CYear BETWEEN (YEAR(CURDATE()) - 3) AND (YEAR(CURDATE()))
      AND SCLID = '000002'
GROUP BY CSemester;


-- (iii.7). Xem 5 lớp học có số sinh viên cao nhất mà giảng viên từng phụ trách.
-- theo Class
CREATE TEMPORARY TABLE CLASS_STUDENT_NUM
SELECT ACID AS CID, COUNT(AStudentID) AS STUDENT_NUM
FROM Attend
WHERE ACID IN (SELECT CCID
               FROM Class, LECTURERS_SUBJECT
               WHERE LID = '000002' AND CSemester = '201' AND CCID = CID)
GROUP BY ACID;

SELECT CID, STUDENT_NUM
FROM CLASS_STUDENT_NUM
LIMIT 5;

--  theo SubClass
CREATE TEMPORARY TABLE SUBCLASS_STUDENT_NUM
SELECT ASID AS SID,COUNT(AStudentID) AS STUDENT_NUM
FROM Attend
WHERE ASID IN (SELECT SID
               FROM SUBCLASS_INFO
               WHERE CID IN (SELECT CCID
                              FROM Class, LECTURERS_SUBJECT
                              WHERE LID = '000002' AND CSemester = '201' AND CCID = CID))
GROUP BY ASID;

SELECT CID, STUDENT_NUM
FROM SUBCLASS_STUDENT_NUM
LIMIT 5;

-- (iii.8). Xem 5 học kỳ có số lớp nhiều nhất mà giảng viên từng phụ trách.
-- theo Class
CREATE TEMPORARY TABLE CLASS_NUM_BY_SEMESTER
SELECT CSemester, COUNT(DISTINCT CID) AS CLASS_NUM
FROM SUBCLASS_INFO
WHERE SCLID = '000002'
GROUP BY CSemester;
SELECT * FROM CLASS_NUM_BY_SEMESTER
ORDER BY CLASS_NUM
LIMIT 5;
DROP TABLE CLASS_NUM_BY_SEMESTER;

-- theo SubClass
CREATE TEMPORARY TABLE SUBCLASS_NUM_BY_SEMESTER
SELECT CSemester, COUNT(SID) AS CLASS_NUM
FROM SUBCLASS_INFO
WHERE SCLID = '000002'
GROUP BY CSemester;
SELECT * FROM SUBCLASS_NUM_BY_SEMESTER
ORDER BY CLASS_NUM
LIMIT 5;
DROP TABLE SUBCLASS_NUM_BY_SEMESTER;
