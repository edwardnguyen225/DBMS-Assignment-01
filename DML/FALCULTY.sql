-- (ii). Khoa quản lý chương trình đào tạo

CREATE VIEW LECTURER_INFO AS 
SELECT LID, LNAME, FNAME, GENDER, DOB, EMAIL
FROM MEMBEROFEDUCATIONUNIT, EMPLOYEE, LECTURER
WHERE ID = PERSONALEID AND EMPLOYEEID = LID;

CREATE VIEW STUDENT_INFO AS
SELECT STUDENTID, LNAME, FNAME, GENDER, DOB, EMAIL
FROM MEMBEROFEDUCATIONUNIT, STUDENT
WHERE ID = PERSONALSID;

CREATE VIEW SUBCLASS_INFO AS
SELECT CID, CYEAR, CSEMESTER, SID, CNAME
FROM SUBCLASS, SUBJECT
WHERE SCID = CID;

-- (ii.1). Cập nhật danh sách môn học được mở trước đầu mỗi học kỳ.
UPDATE SUBJECT
SET STATUS = TRUE
WHERE CID = 'CO2014';

-- (ii.2). Cập nhật danh sách giảng viên phụ trách mỗi lớp học được mở trước đầu mỗi học kỳ.
UPDATE SUBCLASS 
SET SCLID = '000002'
WHERE (2020, '201', 'CO2014', 'L14');

-- (ii.3). Xem danh sách môn học ở một học kỳ.
SELECT *
FROM SUBJECT;

-- (ii.4). Xem danh sách giảng viên ở một học kỳ.
SELECT * 
FROM LECTURER_INFO 
WHERE EXISTS (SELECT * FROM WEEK WHERE WLID = LID AND WSEMESTER = '201');

-- (ii.5). Xem danh sách lớp được phụ trách bởi một giảng viên ở một học kỳ.
SELECT DISTINCT SID, SCID, CNAME
FROM  SUBCLASS, `WEEK`, SUBJECT
WHERE (WYEAR, WSEMESTER, WCID, WSID) = (CYEAR, CSEMESTER, SCID, SID) AND SCID = CID AND WLID = '000002' AND CSEMESTER = '201';

-- (ii.6). Xem danh sách giảng viên phụ trách ở mỗi lớp ở một học kỳ.
SELECT DISTINCT CSEMESTER, CID, SID, CNAME, FNAME, LNAME 
FROM `WEEK`, LECTURER_INFO, SUBCLASS_INFO
WHERE (WYEAR, WSEMESTER, WCID, WSID) = (CYEAR, CSEMESTER, CID, SID) AND WLID = LID AND (CYEAR, CSEMESTER, CID, SID) = (2020, '201', 'CO2014', 'L14');

-- (ii.7). Xem các giáo trình được chỉ định cho mỗi môn học ở một học kỳ.
SELECT CID, CNAME, ISBN, TNAME, TPNAME
FROM SUBJECT, TEXTBOOK, `USE`
WHERE CID = UCID AND UISBN = ISBN AND CID = 'CO2014';

-- (ii.8). Xem danh sách sinh viên đăng ký cho mỗi lớp ở một học kỳ.
SELECT CYEAR, CSEMESTER, SCID, SID, STUDENTID, FNAME, LNAME
FROM STUDENT_INFO, SUBCLASS, ATTEND
WHERE (AYEAR, ASEMESTER, ACID, ASID) = (CYEAR, CSEMESTER, SCID, SID) AND ASTUDENTID = STUDENTID AND (CYEAR, CSEMESTER, SCID, SID) = (2020, '201', 'CO2014', 'L14');

-- (ii.9). Xem tổng số sinh viên đăng ký ở một học kỳ.
SELECT COUNT(DISTINCT STUDENTID) AS NO_STUDENTS 
FROM ATTEND, STUDENT
WHERE ASTUDENTID = STUDENTID AND ASEMESTER = '201';

-- (ii.10). Xem tổng số lớp được mở ở một học kỳ.
SELECT COUNT(*) AS NO_SUBCLASS
FROM SUBCLASS
WHERE CSEMESTER = '201';

-- (ii.11). Xem những môn có nhiều giảng viên cùng phụ trách nhất ở một học kỳ.
SELECT CID, CNAME, COUNT(DISTINCT LID) AS NO_LECTURERS
FROM `WEEK`, LECTURER_INFO, SUBCLASS_INFO
WHERE (WYEAR, WSEMESTER, WCID, WSID) = (CYEAR, CSEMESTER, CID, SID) AND WLID = LID AND CSEMESTER = '201'
GROUP BY CYEAR, CSEMESTER, CID, SID
ORDER BY COUNT(DISTINCT LID);

-- (ii.12). Xem số sinh viên đăng ký trung bình trong 3 năm gần nhất cho một môn học ở một học kỳ.
SELECT SUM(NO_STUDENTS)/3 AS AVG_STUDENTS 
FROM (SELECT COUNT(*) AS NO_STUDENTS
	FROM STUDENT, ATTEND, SUBCLASS_INFO
	WHERE STUDENTID = ASTUDENTID AND (AYEAR, ASEMESTER, ACID, ASID) = (CYEAR, CSEMESTER, CID, SID) 
			AND CYEAR BETWEEN 2018 AND 2020 AND CSEMESTER LIKE '%1' AND CID = 'CO2014'
	GROUP BY CID, CYEAR, CSEMESTER) T;
