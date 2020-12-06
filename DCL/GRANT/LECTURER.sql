DROP VIEW IF EXISTS LECTURER_INFO;
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

DELIMETER $$
CREATE PROCEDURE ADD_MAIN_TEXTBOOK(MCID_IN CHAR(6), MISBD_IN CHAR(7))
BEGIN
   IF (SELECT COUNT(*) FROM MainlyUse WHERE MCID=MCID_IN) = 3 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='There are already 3 main textbook for this subject!';
   ELSE
      INSERT INTO MainlyUse(MCID, MISBD)
      VALUES (MCID_IN, MISBD_IN);
   END IF;
END $$
DELIMETER;

-- Xem các textbook theo môn học của khoa của gv
DELIMETER $$
CREATE PROCEDURE GET_ALL_TEXTBOOK_OF_SUBJECT_OF_LECTURERS_FALCUTY(EmployeeID_IN CHAR(6))
BEGIN
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
            WHERE EmployeeID =EmployeeID_IN));
END $$
DELIMETER;

-- xóa textbook chính theo mã môn học
DELIMETER $$
CREATE PROCEDURE DELETE_ALL_MAIN_TEXTBOOK_OF_SUBJECT(MCID_IN CHAR(6))
BEGIN
  DELETE
   FROM MainlyUse
   WHERE MCID = MCID_IN; 
END $$
DELIMETER;

-- xóa textbook chính

DELIMETER $$
CREATE PROCEDURE DELETE_SPECIFIC_MAIN_TEXTBOOK_OF_SUBJECT(MISBD_IN CHAR(7))
BEGIN
   DELETE
   FROM MainlyUse
   WHERE MISBD = MISBD_IN;
END $$
DELIMETER;

-- (iii.2). Xem danh sách lớp học của mỗi môn học do mình phụ trách ở một học kỳ.
-- danh sách Class
DELIMETER $$
CREATE PROCEDURE GET_LIST_OF_CLASSES_OF_LECTURER_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT CID, CName
   FROM Class, LECTURERS_SUBJECT
   WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID;
END $$
DELIMETER;

-- danh sách SubClass
DELIMETER $$
CREATE PROCEDURE GET_LIST_OF_SUB_CLASSES_OF_LECTURER_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT *
   FROM SUBCLASS_INFO
   WHERE CID IN (SELECT CID
                  FROM Class, LECTURERS_SUBJECT
                  WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID;
                  );
END $$
DELIMETER;


-- (iii.3). Xem danh sách sinh viên của mỗi lớp học do mình phụ trách ở một học kỳ.
-- theo Class
DELIMETER $$
CREATE PROCEDURE GET_LIST_OF_STUDENTS_IN_LECTURER_CLASSES_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT ACID AS CID, StudentID, LName, FName FROM STUDENT_INFO, Attend
   WHERE AStudentID = StudentID
      AND ACID IN (SELECT CCID
                  FROM Class, LECTURERS_SUBJECT
                  WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID)
   ORDER BY ACID;
END $$
DELIMETER;

-- theo SubClass
DELIMETER $$
CREATE PROCEDURE GET_LIST_OF_STUDENTS_IN_LECTURER_CLASSES_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT ASID AS SID, StudentID, LName, FName FROM STUDENT_INFO, Attend
   WHERE AStudentID = StudentID
      AND ASID IN (SELECT SID
                  FROM SUBCLASS_INFO
                  WHERE CID IN (SELECT CCID
                                 FROM Class, LECTURERS_SUBJECT
                                 WHERE LID = LID_IN AND CSemester = CSemester_IN  AND CCID = CID)
                  )
   ORDER BY ASID;
END $$
DELIMETER;


-- (iii.4). Xem danh sách môn học và giáo trình chính cho mỗi môn học do mình phụ
-- trách ở một học kỳ.
DELIMETER $$
CREATE PROCEDURE GET_SUBJECTS_AND_MAIN_TEXTBOOKS_OF_LECTURER_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT CID, CName, TName, ISBN
   FROM LECTURERS_SUBJECT, Textbook, MainlyUse
   WHERE LID = LID_IN
      AND CSemester = CSemester_IN
      AND ISBN = MISBD
      AND MCID = CID
   ORDER BY CID;
END $$
DELIMETER;


-- (iii.5). Xem tổng số sinh viên của mỗi lớp học do mình phụ trách ở một học kỳ.
-- theo Class
DELIMETER $$
CREATE PROCEDURE GET_NUMBER_OF_STUDENTS_IN_MY_CLASSES_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT ACID AS CID, COUNT(AStudentID) AS STUDENT_NUM
   FROM Attend
   WHERE ACID IN (SELECT CCID
                  FROM Class, LECTURERS_SUBJECT
                  WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID)
   GROUP BY ACID;
END $$
DELIMETER;

--  theo SubClass
DELIMETER $$
CREATE PROCEDURE GET_NUMBER_OF_STUDENTS_IN_MY_SUB_CLASSES_BY_SEMESTER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   SELECT ASID AS SID,COUNT(AStudentID) AS STUDENT_NUM
   FROM Attend
   WHERE ASID IN (SELECT SID
                  FROM SUBCLASS_INFO
                  WHERE CID IN (SELECT CCID
                                 FROM Class, LECTURERS_SUBJECT
                                 WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID))
   GROUP BY ASID;
END $$
DELIMETER;


-- (iii.6). Xem số lớp học do mình phụ trách ở mỗi học kỳ trong 3 năm liên tiếp gần đây nhất.
-- theo Class
DELIMETER $$
CREATE PROCEDURE GET_NUMBER_OF_MY_CLASSES_IN_3_YEARS(LID_IN CHAR(6))
BEGIN
   SELECT CSemester, COUNT(DISTINCT CID) AS CLASS_NUM
   FROM SUBCLASS_INFO
   WHERE CYear BETWEEN (YEAR(CURDATE()) - 3) AND (YEAR(CURDATE()))
         AND SCLID = LID_IN
   GROUP BY CSemester;
END $$
DELIMETER;


-- theo SubClass
DELIMETER $$
CREATE PROCEDURE GET_NUMBER_OF_MY_SUB_CLASSES_IN_3_YEARS(LID_IN CHAR(6))
BEGIN
   SELECT CSemester, COUNT(SID) AS CLASS_NUM
   FROM SUBCLASS_INFO
   WHERE CYear BETWEEN (YEAR(CURDATE()) - 3) AND (YEAR(CURDATE()))
         AND SCLID = LID_IN
   GROUP BY CSemester;
END $$
DELIMETER;


-- (iii.7). Xem 5 lớp học có số sinh viên cao nhất mà giảng viên từng phụ trách.
-- theo Class
DELIMETER $$
CREATE PROCEDURE GET_5_OF_MY_CLASSES_HAVING_HIGHEST_STUDENT_NUMBER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   WITH CLASS_STUDENT_NUM AS (
      SELECT ACID AS CID, COUNT(AStudentID) AS STUDENT_NUM
      FROM Attend
      WHERE ACID IN (SELECT CCID
                     FROM Class, LECTURERS_SUBJECT
                     WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID)
      GROUP BY ACID
   )
   SELECT CID, STUDENT_NUM
   FROM CLASS_STUDENT_NUM
   LIMIT 5;
END $$
DELIMETER;


--  theo SubClass
DELIMETER $$
CREATE PROCEDURE GET_5_OF_MY_SUB_CLASSES_HAVING_HIGHEST_STUDENT_NUMBER(LID_IN CHAR(6), CSemester_IN CHAR(3))
BEGIN
   WITH CLASS_STUDENT_NUM AS (
      SELECT ASID AS SID,COUNT(AStudentID) AS STUDENT_NUM
      FROM Attend
      WHERE ASID IN (SELECT SID
                     FROM SUBCLASS_INFO
                     WHERE CID IN (SELECT CCID
                                    FROM Class, LECTURERS_SUBJECT
                                    WHERE LID = LID_IN AND CSemester = CSemester_IN AND CCID = CID))
      GROUP BY ASID
   )
   SELECT CID, STUDENT_NUM
   FROM SUBCLASS_STUDENT_NUM
   LIMIT 5;
END $$
DELIMETER;


-- (iii.8). Xem 5 học kỳ có số lớp nhiều nhất mà giảng viên từng phụ trách.
-- theo Class
DELIMETER $$
CREATE PROCEDURE GET_5_SEMESTER_HAVING_HIGHEST_CLASSES_NUM_OF_LECTURER(LID_IN CHAR(6))
BEGIN
   WITH CLASS_NUM_BY_SEMESTER AS (
      SELECT CSemester, COUNT(DISTINCT CID) AS CLASS_NUM
      FROM SUBCLASS_INFO
      WHERE SCLID = LID_IN
      GROUP BY CSemester
   )
   SELECT * FROM CLASS_NUM_BY_SEMESTER
   ORDER BY CLASS_NUM
   LIMIT 5;
END $$
DELIMETER;


-- theo SubClass
DELIMETER $$
CREATE PROCEDURE GET_5_SEMESTER_HAVING_HIGHEST_SUB_CLASSES_NUM_OF_LECTURER(LID_IN CHAR(6))
BEGIN
   WITH SUBCLASS_NUM_BY_SEMESTER AS (
      SELECT CSemester, COUNT(SID) AS CLASS_NUM
      FROM SUBCLASS_INFO
      WHERE SCLID = LID_IN
      GROUP BY CSemester
   )
   SELECT * FROM SUBCLASS_NUM_BY_SEMESTER
   ORDER BY CLASS_NUM
   LIMIT 5;
END $$
DELIMETER;

