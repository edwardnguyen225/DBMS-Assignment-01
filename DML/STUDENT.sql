USE Learning_Teaching;

/* Xem danh sách môn học, lớp học, và các giảng viên phụ trách cho mỗi lớp của mỗi môn học ở học kỳ được đăng ký. */
SELECT CNAME,
       SID,
       MOEU.Lname,
       ASemester
FROM SubClass SC,
     Lecturer L,
     Employee E,
     MemberOfEducationUnit MOEU,
     Subject SJ,
     Attend AT,
            Student ST
WHERE ST.StudentID='1814812'
  AND ST.StudentID=AT.AStudentID
  AND AT.ASemester=SC.CSemester
  AND SC.SCID=AT.ACID
  AND SC.SID=AT.ASID
  AND SC.SCLID=L.LID
  AND SJ.CID=SC.SCID
  AND E.EmployeeID=L.LID
  AND MOEU.ID=E.PersonalEID;

/*Xem danh sách môn học và giáo trình chính cho mỗi môn học mà mình đăng ký ở một học kỳ.*/
SELECT CName,
       TName
FROM Subject
JOIN MainlyUse MU ON Subject.CID = MU.MCID
JOIN Textbook T ON MU.MISBD = T.ISBN,(Student
                                      JOIN Attend A ON Student.StudentID = A.AStudentID)
WHERE AStudentID='1814812'
  AND ASemester=201
  AND ACID=CID;

/*Xem danh sách lớp học của mỗi môn học mà mình đăng ký ở một học kỳ.*/
SELECT CName,
       SID,
       SCID
FROM SubClass
JOIN Subject ON SubClass.SCID=Subject.CID,
                Student
JOIN Attend A ON Student.StudentID = A.AStudentID
WHERE AStudentID='1814812'
  AND ASemester=201
  AND ACID=CID;

/*Xem danh sách lớp học của mỗi môn học mà mình đăng ký có nhiều hơn 1 giảng viên phụ trách ở một học kỳ.*/
SELECT CName,
       SID,
       SCID,
       Lname
FROM SubClass
JOIN Subject ON (SubClass.SCID=Subject.CID)
JOIN Lecturer L ON (SubClass.SCLID = L.LID)
JOIN Employee E ON (L.LID = E.EmployeeID)
JOIN MemberOfEducationUnit MOEU ON (E.PersonalEID = MOEU.ID),Student
JOIN Attend A ON Student.StudentID = A.AStudentID
WHERE AStudentID='1814812'
  AND ASemester=201
  AND ACID=CID
  AND exists
    (SELECT count(*)
     FROM Lecturer LL, SubClass sc
     WHERE sc.SCID=CID
       AND sc.SCLID= LID
     GROUP BY sc.SCID
     HAVING count(*)>1);

*/ SXem tổng số tín chỉ đã đăng ký được ở một học kỳ.*/
SELECT sum(NoCredits)
FROM SubClass
JOIN Subject ON (SubClass.SCID=Subject.CID),Student
JOIN Attend A ON Student.StudentID = A.AStudentID
WHERE AStudentID='1814812'
  AND ASemester=201
  AND ACID=CID
  AND ASID=SID
  AND ASemester=CSemester;

/*Xem tổng số môn học đã đăng ký được ở một học kỳ.*/
SELECT COUNT(*)
FROM SubClass,
     Student
JOIN Attend A ON Student.StudentID = A.AStudentID
WHERE AStudentID='1814812'
  AND ASemester=201
  AND ACID=SCID
  AND ASID=SID
  AND ASemester=CSemester;

/*Xem 3 học kỳ có số tổng số tín chỉ cao nhất mà mình đã từng đăng ký.*/
CREATE VIEW Nocreadit_semeter AS
SELECT sum(NoCredits) SUM,
                      ASemester
FROM SubClass
JOIN Subject ON (SubClass.SCID=Subject.CID),Student
JOIN Attend A ON Student.StudentID = A.AStudentID
WHERE AStudentID='1814812'
  AND ACID=CID
  AND ASID=SID
  AND ASemester=CSemester
GROUP BY ASemester;


SELECT *
FROM Nocreadit_semeter;


SELECT ASemester
FROM Nocreadit_semeter
ORDER BY SUM DESC
LIMIT 3;
