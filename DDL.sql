DROP SCHEMA IF EXISTS Learning_Teaching;

CREATE SCHEMA Learning_Teaching;

CREATE TABLE Learning_Teaching.MemberOfEducationUnit(
    ID CHAR(9),
    Gender CHAR,
    Fname VARCHAR(15) NOT NULL,
    Lname VARCHAR(30) NOT NULL,
    DOB DATE,
    Email VARCHAR(50),
    PRIMARY KEY (ID)
);

CREATE TABLE Learning_Teaching.Employee(
    EmployeeID CHAR(6),
    PersonalEID CHAR(9) UNIQUE NOT NULL,
    PRIMARY KEY (EmployeeID),
    FOREIGN KEY (PersonalEID) REFERENCES MemberOfEducationUnit(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Student(
    StudentID CHAR(7),
    YearofAdmission YEAR NOT NULL,
    PersonalSID CHAR(9) UNIQUE NOT NULL,
    PRIMARY KEY (StudentID),
    FOREIGN KEY (PersonalSID) REFERENCES MemberOfEducationUnit(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.AAOEmployee(
    AEID CHAR(6),
    PRIMARY KEY (AEID),
    FOREIGN KEY (AEID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.SeniorLecturer(
    SLID CHAR(6),
    PRIMARY KEY (SLID),
    FOREIGN KEY (SLID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Lecturer(
    LID CHAR(6),
    PRIMARY KEY (LID),
    FOREIGN KEY (LID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Faculty(
    FacultyName VARCHAR(70),
    PRIMARY KEY (FacultyName)
);

CREATE TABLE Learning_Teaching.`Subject`(
    CID CHAR(6),
    CName VARCHAR(50) NOT NULL,
    STATUS BOOLEAN,
    NoCredits INT NOT NULL,
    PRIMARY KEY (CID),
    CONSTRAINT subject_1 CHECK (
        NoCredits BETWEEN 1
        AND 3
    )
);

CREATE TABLE Learning_Teaching.Textbook(
    ISBN CHAR(7),
    TName VARCHAR(50) NOT NULL,
    PRIMARY KEY (ISBN)
);

CREATE TABLE Learning_Teaching.Author(
    AID CHAR(7),
    AName VARCHAR(50) NOT NULL,
    PRIMARY KEY (AID)
);

CREATE TABLE Learning_Teaching.Publisher(
    PName VARCHAR(50),
    Location VARCHAR(80),
    PRIMARY KEY (PName)
);

CREATE TABLE Learning_Teaching.Class(
    `Year` YEAR,
    Semester CHAR(3),
    CCID CHAR(6),
    PRIMARY KEY (`Year`, Semester, CCID),
    FOREIGN KEY (CCID) REFERENCES Subject(CID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.SubClass(
    CYear YEAR,
    CSemester CHAR(3),
    SCID CHAR(6),
    SID CHAR(3),
    PRIMARY KEY (CYear, CSemester, SCID, SID),
    FOREIGN KEY (CYear, CSemester, SCID) REFERENCES Class(`Year`, Semester, CCID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.`Week`(
    WYear YEAR,
    WSemester CHAR(3),
    WCID CHAR(6),
    WSID CHAR(3),
    Number INT,
    PRIMARY KEY (WYear, WSemester, WCID, WSID, Number),
    FOREIGN KEY (WYear, WSemester, WCID, WSID) REFERENCES SubClass(CYear, CSemester, SCID, SID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.`Use`(
    UCID CHAR(6),
    UISBN CHAR(7),
    PRIMARY KEY (UCID, UISBN),
    FOREIGN KEY (UCID) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UISBN) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.MainlyUse(
    MCID CHAR(6),
    MISBD CHAR(7),
    PRIMARY KEY (MCID, MISBD),
    FOREIGN KEY (MCID) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MISBD) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Prerequisite(
    Csuper CHAR(6),
    Csub CHAR(6),
    PRIMARY KEY (Csuper, Csub),
    FOREIGN KEY (Csuper) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Csub) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Parallel(
    Psuper CHAR(6),
    Psub CHAR(6),
    PRIMARY KEY (Psuper, Psub),
    FOREIGN KEY (Psuper) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Psub) REFERENCES `Subject`(CID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Attend(
    AYear YEAR,
    ASemester CHAR(3),
    ACID CHAR(6),
    ASID CHAR(3),
    AStudentID CHAR(7),
    PRIMARY KEY (AYear, ASemester, ACID, ASID, AStudentID),
    FOREIGN KEY (AStudentID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (AYear, ASemester, ACID, ASID) REFERENCES SubClass(CYear, CSemester, SCID, SID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Manage(
    MLID CHAR(6),
    MYear YEAR,
    MSemester CHAR(3),
    MCID CHAR(6),
    MISBN CHAR(7),
    PRIMARY KEY (MLID, MYear, MSemester, MCID, MISBN),
    FOREIGN KEY (MLID) REFERENCES Lecturer(LID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MYear, MSemester, MCID) REFERENCES Class(`Year`, Semester, CCID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MISBN) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.Written_by(
    WISBN CHAR(7),
    WAID CHAR(7),
    PRIMARY KEY (WISBN, WAID),
    FOREIGN KEY (WAID) REFERENCES Author(AID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (WISBN) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE
    Learning_Teaching.Employee
ADD
    (FEName VARCHAR(70) NOT NULL);

ALTER TABLE
    Learning_Teaching.Employee
ADD
    FOREIGN KEY (FEName) REFERENCES Faculty(FacultyName) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.Student
ADD
    (FSName VARCHAR(70));

ALTER TABLE
    Learning_Teaching.Student
ADD
    FOREIGN KEY (FSName) REFERENCES Faculty(FacultyName) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.`Subject`
ADD
    (FCName VARCHAR(70) NOT NULL);

ALTER TABLE
    Learning_Teaching.`Subject`
ADD
    FOREIGN KEY (FCName) REFERENCES Faculty(FacultyName) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.SubClass
ADD
    (SCLID CHAR(6) NOT NULL);

ALTER TABLE
    Learning_Teaching.SubClass
ADD
    FOREIGN KEY (SCLID) REFERENCES Lecturer(LID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.`Week`
ADD
    (WLID CHAR(6));

ALTER TABLE
    Learning_Teaching.`Week`
ADD
    FOREIGN KEY (WLID) REFERENCES Lecturer(LID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.Lecturer
ADD
    (LSLID CHAR(6));

ALTER TABLE
    Learning_Teaching.Lecturer
ADD
    FOREIGN KEY (LSLID) REFERENCES SeniorLecturer(SLID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE
    Learning_Teaching.Textbook
ADD
    (TPName CHAR(50) NOT NULL);

ALTER TABLE
    Learning_Teaching.Textbook
ADD
    FOREIGN KEY (TPName) REFERENCES Publisher(Pname) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE Learning_Teaching.Phone(
    MOEID CHAR(9),
    PhoneNumber CHAR(11),
    PRIMARY KEY (MOEID, PhoneNumber),
    FOREIGN KEY (MOEID) REFERENCES MemberOfEducationUnit(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.`Status`(
    SSID CHAR(7),
    SemesterStatus CHAR(3),
    LearningStatus INT,
    PRIMARY KEY (SSID, SemesterStatus, LearningStatus),
    FOREIGN KEY (SSID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT status_1 CHECK (
        LearningStatus BETWEEN 0
        AND 2
    )
);

CREATE TABLE Learning_Teaching.Category(
    CISBN CHAR(7),
    CategoryName VARCHAR(15),
    PRIMARY KEY (CISBN, CategoryName),
    FOREIGN KEY (CISBN) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Learning_Teaching.PublishingYear(
    PYISBN CHAR(7),
    PYear YEAR,
    PRIMARY KEY (PYISBN, PYear),
    FOREIGN KEY (PYISBN) REFERENCES Textbook(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);