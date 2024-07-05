CREATE DATABASE Advising_Team_23
--DROP DATABASE Advising_Team_23


Use Advising_Team_23
GO 
CREATE PROC CreateAllTables

AS

CREATE TABLE Course (
course_id int not null IDENTITY,
name varchar(40),
major varchar(40),
is_offered bit,
credit_hours int,
semester int,
CONSTRAINT pk_constraint PRIMARY KEY (course_id)
);

CREATE TABLE Instructor(

instructor_id int not null identity,
name varchar(40),
email varchar(40),
faculty varchar(40),
office varchar(40),
CONSTRAINT pk_constraint1 PRIMARY KEY (instructor_id)
);

CREATE TABLE Semester (
semester_code varchar(40), 
start_date DATE, 
end_date DATE,
CONSTRAINT pk_constraint2 PRIMARY KEY (semester_code)
);

CREATE TABLE Advisor (
advisor_id int not null identity, 
name varchar(40), 
email varchar(40), 
office varchar(40), 
password varchar(40),

CONSTRAINT pk_constraint3 PRIMARY KEY (advisor_id)
);

CREATE TABLE Student (
student_id int not null identity, 
f_name varchar(40), 
l_name varchar(40), 
gpa decimal, 
faculty varchar(40), 
email varchar(40), 
major varchar(40),
password varchar(40), 
semester int, 
acquired_hours int, 
assigned_hours int,
advisor_id int,
installment_deadline timestamp,
installment_status bit,
--CONSTRAINT fk_constraint1 FOREIGN KEY (installment_deadline) REFERENCES Installment (deadline),-- ON DELETE CASCADE
--ON UPDATE CASCADE,
--CONSTRAINT fk_constraint2 FOREIGN KEY (installment_status) REFERENCES Installment (status), --ON DELETE CASCADE
--ON UPDATE CASCADE,
CONSTRAINT pk_constraint4 PRIMARY KEY (student_id),
CONSTRAINT fk_constraint3 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id), --ON DELETE CASCADE
--ON UPDATE CASCADE,
--financial_status as @temp
financial_status bit --AS CASE WHEN CURRENT_TIMESTAMP > installment_deadline AND installment_status = 0 THEN 0 ELSE 1 END
);

CREATE TABLE Student_Phone(
student_id int not null,
phone_number varchar(40) not null,
CONSTRAINT pk_constraint5 PRIMARY KEY (student_id , phone_number),
CONSTRAINT fk_constraint4 FOREIGN KEY (student_id) REFERENCES Student (student_id)-- ON DELETE CASCADE
--ON UPDATE CASCADE
);

CREATE TABLE PreqCourse_course(

prerequisite_course_id int not null,
course_id int not null,

CONSTRAINT fk_constraint5 FOREIGN KEY (prerequisite_course_id) REFERENCES Course (course_id), 
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint6 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT pk_constraint6 PRIMARY KEY (course_id , prerequisite_course_id)

);

CREATE TABLE Instructor_Course(

course_id int not null,
instructor_id int not null,

CONSTRAINT pk_constraint7 PRIMARY KEY (instructor_id,course_id),

CONSTRAINT fk_constraint7 FOREIGN KEY (course_id) REFERENCES Course (course_id), 
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint8 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE
);

CREATE TABLE Student_Instructor_Course_Take(

student_id int not null,
course_id int not null,
instructor_id int not null,
semester_code varchar(40), --not int--
exam_type VARCHAR(40) DEFAULT 'Normal' CHECK (exam_type IN ('Normal','First_makeup', 'Second_makeup')),
grade Varchar(40) DEFAULT null,

CONSTRAINT fk_constraint9 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint10 FOREIGN KEY (course_id) REFERENCES Course (Course_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint11 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT pk_constraint8 PRIMARY KEY (course_id,student_id,semester_code)
);


CREATE TABLE Course_Semester (
course_id int not null, --not varchar--
semester_code varchar(40) not null,

CONSTRAINT pk_constraint9 PRIMARY KEY (course_id,semester_code),

CONSTRAINT fk_constraint12 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint13 FOREIGN KEY (course_id) REFERENCES Course (Course_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE,
);


CREATE TABLE Slot (
slot_id int not null identity, 
day varchar(40) ,
-- check again hewar day
time varchar(40), 
location varchar(40),
course_id int, --not varchar--
instructor_id int,

CONSTRAINT pk_constraint10 PRIMARY KEY (slot_id),

CONSTRAINT fk_constraint14 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint15 FOREIGN KEY (course_id) REFERENCES Course (Course_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE,
);

CREATE TABLE Graduation_Plan(
plan_id int not null identity,
semester_code varchar (40),
semester_credit_hours int ,
expected_grad_date date,
advisor_id int, --not varchar--
student_id int, --not varchar--

CONSTRAINT pk_constraint11 PRIMARY KEY (plan_id, semester_code),

CONSTRAINT fk_constraint16 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id),
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint17 FOREIGN KEY (student_id) REFERENCES Student (student_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE,
);

CREATE TABLE GradPlan_Course (
plan_id int not null,
semester_code varchar(40) not null,
course_id int, --not varchar--

CONSTRAINT pk_constraint12 PRIMARY KEY (plan_id, course_id,semester_code),

CONSTRAINT fk_constraint18 FOREIGN KEY (plan_id, semester_code) 
REFERENCES Graduation_Plan (plan_id, semester_code), 
--ON DELETE CASCADE
--ON UPDATE CASCADE,

--CONSTRAINT fk_constraint19 FOREIGN KEY (semester_code) REFERENCES Graduation_Plan (semester_code) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint20 FOREIGN KEY (course_id) REFERENCES Course (Course_id) --negbha meninnnnnnnnnnn ma3moola primary bas-
--ON DELETE CASCADE
--ON UPDATE CASCADE
);

CREATE TABLE Request (
request_id int identity not null, 
type varchar(40) CHECK (type IN ('credit_hours','course')), 
comment varchar(40), 
status varchar(40) DEFAULT 'pending' CHECK (status IN ('pending','approved', 'rejected')), 
credit_hours int, 
student_id int,
advisor_id int, 
course_id int, --not varchar--

CONSTRAINT pk_constraint13 PRIMARY KEY (request_id),

CONSTRAINT fk_constraint21 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint22 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE

CONSTRAINT fk_constraint23 FOREIGN KEY (course_id) REFERENCES Course (Course_ID) 
--ON DELETE CASCADE
--ON UPDATE CASCADE,
);

CREATE TABLE MakeUp_Exam (
exam_id int not null identity, 
date DATETIME, 
type varchar(40) CHECK (type IN ('First MakeUp','Second MakeUp')),
course_id int, --not varchar--

CONSTRAINT pk_constraint14 PRIMARY KEY (exam_id),

CONSTRAINT fk_constraint24 FOREIGN KEY (course_id) REFERENCES Course (course_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE
);

CREATE TABLE Exam_Student (
exam_id int not null, 
student_id int, 
course_id int, --not varchar--

CONSTRAINT pk_constraint15 PRIMARY KEY (exam_id, student_id),

CONSTRAINT fk_constraint25 FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint26 FOREIGN KEY (student_id) REFERENCES Student (student_id),
--ON DELETE CASCADE
--ON UPDATE CASCADE
CONSTRAINT fk_constraint27 FOREIGN KEY (course_id) REFERENCES Course (Course_id) --- nnegbhaaaaaa menin
);

CREATE TABLE Payment (
payment_id int identity not null, 
amount int ,
deadline DATETIME, 
n_installments int not null default 0 , --not as month(deadline)-month(start_date)--
status varchar(40) default 'notPaid' CHECK (status IN ('notPaid','Paid')),
fund_percentage decimal, 
student_id int, 
semester_code varchar(40), 
start_date datetime, --not date--

CONSTRAINT pk_constraint16 PRIMARY KEY (payment_id),

CONSTRAINT fk_constraint28 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code),
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint29 FOREIGN KEY (student_id) REFERENCES Student (student_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE
);

CREATE TABLE Installment (
payment_id int not null, 
deadline  datetime,
amount int,
status varchar(40) default  'notPaid' CHECK (status IN ('notPaid','Paid')), 
start_date datetime, --startdate of first installement is the same as the payment

CONSTRAINT pk_constraint17 PRIMARY KEY (payment_id, deadline),

CONSTRAINT fk_constraint30 FOREIGN KEY (payment_id) REFERENCES payment (payment_id) 
--ON DELETE CASCADE
--ON UPDATE CASCADE
);


--Drop all tables
GO
CREATE PROC DropAllTables
AS 
Begin

Drop table Installment;
Drop table Payment;
Drop table Exam_Student;
Drop table MakeUp_Exam;
Drop table Request;
Drop table GradPlan_Course;
Drop table Graduation_Plan;
Drop table Slot;
Drop table Course_Semester;
Drop table Student_Instructor_Course_Take;
Drop table Instructor_Course;
Drop table PreqCourse_course;
Drop table Student_Phone;
Drop table Student;
Drop table Advisor;
Drop table Semester;
Drop table Instructor;
Drop table Course;
End;

EXEC DropAllTables

go
CREATE PROCEDURE clearAllTables
AS
BEGIN

Delete From  Installment;
Delete From  Payment;
Delete From  Exam_Student;
Delete From  MakeUp_Exam;
Delete From  Request;
Delete From  GradPlan_Course;
Delete From  Graduation_Plan;
Delete From  Slot;
Delete From  Course_Semester;
Delete From  Student_Instructor_Course_Take;
Delete From  Instructor_Course;
Delete From  PreqCourse_course;
Delete From  Student_Phone;
Delete From  Student;
Delete From  Advisor;
Delete From  Semester;
Delete From  Instructor;
Delete From  Course;
End;


GO
CREATE FUNCTION [UpdateStudentStatus]
(@StudentID int)
Returns bit
As
begin
Declare @financial_status bit
Declare @deadline datetime
Declare @status varchar(40)
Select @deadline = i.installment_deadline, @status = i.installment_status
From Installment i inner join Payment p on i.payment_id = p.payment_id
Where p.student_id  = @StudentID
if (CURRENT_TIMESTAMP>installment_deadline) AND (installment_status=0)
begin
	set @financial_status=0
end
	else
begin
	set @financial_status=1
end
Return @financial_status
end

--------------------------------malak
Go
CREATE VIEW  VIEW_STUDENTS  AS
SELECT * FROM STUDENT s WHERE s.financial_status= 1
--active?
GO
CREATE VIEW  VIEW_COURSE_PREREQUISITES AS
--PREREQ
SELECT COURSE.* , PreqCourse_course.prerequisite_course_id FROM COURSE 
INNER JOIN PreqCourse_course ON (PreqCourse_course.course_id = COURSE.course_id)
GO

CREATE VIEW Instructors_AssignedCourses AS --all? even if they don't
SELECT INSTRUCTOR.* , COURSE.NAME CourseName
FROM INSTRUCTOR
INNER JOIN INSTRUCTOR_COURSE ON INSTRUCTOR_COURSE.instructor_id = INSTRUCTOR.instructor_id
INNER JOIN COURSE ON INSTRUCTOR_COURSE.COURSE_ID = COURSE.COURSE_ID;
GO 

CREATE VIEW  Student_Payment AS 
SELECT PAYMENT.*, f_name, l_name FROM PAYMENT 
INNER JOIN STUDENT ON STUDENT.STUDENT_ID=PAYMENT.STUDENT_ID

GO
CREATE VIEW Courses_Slots_Instructor AS
SELECT 
    COURSE.COURSE_ID AS 'CourseID',
    COURSE.NAME AS 'Course.Name',
    SLOT.SLOT_ID AS 'Slot ID',
    SLOT.DAY AS 'Slot Day',
    SLOT.TIME  AS 'Slot Time',
    SLOT.LOCATION  AS 'Slot Location',
    INSTRUCTOR.NAME AS 'Slot Instructor Name'
FROM COURSE
INNER JOIN SLOT ON COURSE.COURSE_ID = SLOT.COURSE_ID
INNER JOIN INSTRUCTOR ON SLOT.INSTRUCTOR_ID = INSTRUCTOR.INSTRUCTOR_ID ---check again fih slots fadya wala la2
GO
CREATE VIEW COURSES_MAKEUPEXAMS AS
SELECT COURSE.NAME  AS 'Course name' ,SEMESTER.SEMESTER_CODE  AS 'Course Semester', MAKEUP_EXAM.EXAM_ID ,MAKEUP_EXAM.DATE,MAKEUP_EXAM.TYPE,MAKEUP_EXAM.COURSE_ID FROM COURSE
INNER JOIN MAKEUP_EXAM ON MAKEUP_EXAM.COURSE_ID =COURSE.COURSE_ID --inner join 
INNER JOIN COURSE_SEMESTER ON COURSE_SEMESTER.COURSE_ID= COURSE.COURSE_ID--inner join
INNER JOIN SEMESTER ON SEMESTER.SEMESTER_CODE=COURSE_SEMESTER.SEMESTER_CODE --inner join

GO
CREATE VIEW STUDENTS_COURSES_TRANSCRIPT AS
SELECT STUDENT.STUDENT_ID AS 'Student id', STUDENT.F_NAME +' ' + STUDENT.L_NAME as 'student name',
COURSE.COURSE_ID AS 'course id',
COURSE.NAME AS 'course name',
STIC.EXAM_TYPE AS'exam type',
STIC.GRADE AS 'course grade',
STIC.SEMESTER_CODE AS 'semester',
INSTRUCTOR.NAME AS 'Instructor name' FROM STUDENT 
INNER JOIN Student_Instructor_Course_Take STIC ON  STUDENT.STUDENT_ID=STIC.STUDENT_ID
INNER JOIN COURSE ON STIC.COURSE_ID=COURSE.COURSE_ID
INNER JOIN INSTRUCTOR ON STIC.instructor_id=INSTRUCTOR.INSTRUCTOR_ID

GO


CREATE VIEW SEMSTER_OFFERED_COURSES AS
SELECT COURSE.COURSE_ID AS 'Course id' , COURSE.NAME AS 'Course name', SEMESTER.SEMESTER_CODE AS 'Semester code'
FROM  SEMESTER
INNER JOIN COURSE_SEMESTER ON SEMESTER.SEMESTER_CODE= COURSE_SEMESTER.SEMESTER_CODE--INNERJOIN
INNER JOIN COURSE ON  COURSE.COURSE_ID=COURSE_SEMESTER.COURSE_ID--INNERJOIN

--GROUP BY 

GO
----AW BAS B 
-----------------------MIKHAAAAA
CREATE VIEW Advisors_Graduation_Plan AS
SELECT gp.plan_id, gp.semester_code, gp.semester_credit_hours , gp.expected_grad_date ,gp.student_id, a.advisor_id as 'Advisor id' ,a.name as 'Advisor name'
FROM Graduation_Plan gp inner join Advisor a
on gp.advisor_id = a.advisor_id

---a)
GO
CREATE PROCEDURE Procedures_StudentRegistration

@first_name varchar (40), 
@last_name varchar (40),
@password varchar (40), 
@faculty varchar (40), 
@email varchar(40), 
@major varchar (40), 
@Semester int,
@Student_id int OUTPUT

AS

INSERT INTO Student (f_name,l_name,faculty,email,major,password,semester)
VALUES (@first_name,@last_name,@faculty,@email,@major,@password,@semester);

SELECT @Student_id=student_id FROM Student WHERE  @first_name = f_name and  @last_name = l_name and @password=password and 
@faculty=faculty and @email=email and  @major=major and @Semester = semester 

GO


---B)

CREATE PROCEDURE Procedures_AdvisorRegistration

@advisor_name varchar (40),
@password varchar (40),
@email varchar (40),
@Office varchar(40),
@Advisor_id int OUTPUT 

AS
INSERT INTO Advisor (name, email, office, password )
VALUES (@advisor_name , @email , @office ,@password );

SELECT @Advisor_id = advisor_id FROM Advisor WHERE @advisor_name = name and @email = email and @office = office and  @password = password  ;

GO
--C) 
CREATE PROCEDURE Procedures_AdminListStudents

AS 

SELECT f_name , l_name FROM Student;

GO 
--D) 

CREATE PROCEDURE Procedures_AdminListAdvisors 

AS 

SELECT name FROM Advisor ;

GO


--E)

CREATE PROCEDURE AdminListStudentsWithAdvisors

AS 

SELECT Student.f_name + ' ' + Student.l_name as 'student_name' , Advisor.name as 'advisor_name'
FROM Student 
INNER JOIN Advisor  On Student.advisor_id = Advisor.advisor_id

GO

--F)

CREATE PROCEDURE AdminAddingSemester

@start_date date ,
@end_date date,
@semester_code varchar(40) 

AS

INSERT INTO Semester (semester_code , start_date , end_date )
VALUES (@semester_code , @start_date , @end_date );

GO 

--G)

CREATE PROCEDURE Procedures_AdminAddingCourse

@major varchar(40),
@semester int,
@credit_hours int ,
@course_name varchar(40),
@offered bit 

AS

INSERT INTO  Course ( name , major , is_offered ,credit_hours , semester) 
VALUES (@course_name, @major , @offered,@credit_hours, @semester );

GO


--H)


CREATE PROCEDURE Procedures_AdminLinkInstructor

@InstructorId int,
@courseId int,
@slotID int

AS

--set identity_insert Slot ON;

INSERT INTO Instructor_Course (course_id , instructor_id)
VALUES ( @courseId , @InstructorId);

update Slot SET course_id=@courseId , instructor_id=@InstructorId WHERE slot_id = @slotID


--set identity_insert Slot OFF;

GO

--I)

CREATE PROCEDURE Procedures_AdminLinkStudent

@Instructor_Id int, 
@student_ID int, 
@course_ID int,
@semester_code varchar (40)

AS 

--set identity_insert  Student_Instructor_Course_Take ON;

INSERT INTO Student_Instructor_Course_Take (student_id , course_id ,instructor_id , semester_code)
VALUES(@student_Id,@course_ID,@Instructor_ID,@semester_code);

--set identity_insert  Student_Instructor_Course_Take OFF;

GO




-- to be checked MARLY

--j
CREATE PROC [Procedures_AdminLinkStudentToAdvisor]
@studentID int,
@advisorID int
AS
IF @studentID IS NULL  or @advisorID IS NULL begin 
print 'One or more of the inputs is null'
end
ELSE begin
UPDATE Student SET advisor_id = @advisorID WHERE student_id = @studentID;
end
GO

--k
CREATE PROC [Procedures_AdminAddExam] --should we check if any of those is null?
@Type varchar (40), 
@date datetime, 
@courseID int
AS
INSERT INTO MakeUp_Exam (date, type, course_id) VALUES (@date, @type, @courseID);
GO

--l  
CREATE PROC [Procedures_AdminIssueInstallment]
@paymentID int
AS

DECLARE @deadline datetime
DECLARE @start datetime
DECLARE @amount int
DECLARE @noInst int
DECLARE @i INTEGER

SELECT @start = p.start_date, @deadline = p.deadline, @amount = p.amount, @noInst = n_installments
FROM Payment p 
WHERE p.payment_id =  @paymentID

DECLARE @installment_start datetime
SET @installment_start = @start 
SET @i = 1;

DECLARE @installment_deadline datetime
SET @installment_deadline = DATEADD(MONTH, 1, @installment_start);

DECLARE @installment_amount int
SET @installment_amount = @amount/@noInst;

WHILE @i < @noInst
BEGIN
   INSERT INTO Installment (payment_id, deadline, amount, status, start_date) 
   VALUES (@paymentID, @installment_deadline,@installment_amount, 'notPaid', @installment_start)
   SET @installment_deadline = DATEADD(MONTH, 1, @installment_deadline);
   SET @installment_start = DATEADD(MONTH, 1, @installment_start);
   SET @i = @i + 1;
END;
GO

--m
CREATE PROC [Procedures_AdminDeleteCourse]
@courseID int
AS
DELETE FROM Course WHERE course_id = @courseID;
DELETE FROM Slot WHERE course_id = @courseID; 
GO

--n
CREATE PROC [Procedure_AdminUpdateStudentStatus] 
@StudentID int
AS

DECLARE @status varchar(40)
DECLARE @deadline datetime

SELECT @status = i.status, @deadline = i.deadline
FROM Student s inner join Payment p ON s.student_id = p.student_id 
inner join Installment i ON i.payment_id = p.payment_id
WHERE s.student_id = @StudentID
IF @status = 'notPaid' and CURRENT_TIMESTAMP > @deadline begin 
UPDATE Student SET financial_status = 0 WHERE student_id = @StudentID
end
ELSE begin
UPDATE Student SET financial_status = 1 WHERE student_id = @StudentID
end
GO

--o 
CREATE VIEW all_Pending_Requests
AS
SELECT r.request_id, r.type, r.comment, r.status, r.credit_hours,
s.f_name+ ' ' + s.l_name as 'initiated student name', a.name as 'Related advisor name'
FROM Request r inner join Student s on r.student_id = s.student_id
inner join Advisor a on r.advisor_id = a.advisor_id
WHERE status = 'pending'
GO

--p 
CREATE PROC [Procedures_AdminDeleteSlots]
@current_semester varchar (40)
AS

DECLARE @CID int

SELECT @CID = c.course_id
FROM Course c
WHERE not exists (select cs1.course_id
FROM Course_Semester cs1 
WHERE cs1.course_id = @CID and cs1.semester_code = @current_semester)

DELETE FROM Slot WHERE course_id = @CID;

GO

--q
CREATE FUNCTION [FN_AdvisorLogin]
(@ID int, @password varchar (40))
Returns bit
AS
begin 
Declare @success bit
if (exists(select *
From advisor a 
Where a.advisor_id = @ID and a.password = @password))
Set @success = 1
else set @success = 0
Return @success
end
GO


--r 
CREATE PROC [Procedures_AdvisorCreateGP]
@SemesterCode varchar (40), 
@expected_graduation_date date, 
@sem_credit_hours int, 
@advisorID int,
@studentID int
AS

INSERT INTO Graduation_Plan (semester_code, semester_credit_hours, expected_grad_date, advisor_id, student_id)
VALUES (@SemesterCode, @sem_credit_hours, @expected_graduation_date, @advisorID, @studentID);
GO

--s
CREATE PROC [Procedures_AdvisorAddCourseGP]
@studentID int, 
@Semester_code varchar (40), 
@course_name varchar (40)
AS 
DECLARE @acquired_hours int
SELECT @acquired_hours = s.acquired_hours
FROM Student s WHERE s.student_id = @studentID
if @acquired_hours > 157
begin 
DECLARE @CID int
DECLARE @PID int

SELECT @CID = course_id 
FROM Course 
WHERE name = @course_name

SELECT @PID = plan_id
FROM Graduation_Plan
WHERE student_id = @studentID

INSERT INTO GradPlan_Course (plan_id, semester_code, course_id) VALUES (@PID, @Semester_code, @CID);
end 
else 
begin
print ('Insufficient student hours')
end
GO

---------------------- Hamza

-- T)
--Double check
Create Proc Procedures_AdvisorUpdateGP
(
@studentID int
,@expected_grad_semester varchar(40)
)
AS
begin
UPDATE Graduation_Plan
Set expected_grad_date = @expected_grad_semester
WHERE student_id = @studentID;
END;
GO
--Select * from Graduation_Plan
--exec Procedures_AdvisorUpdateGP 1,'2024-01-30' 


-- U)
--Double check
Create Proc Procedures_AdvisorDeleteFromGP
(
    @studentID int,
    @semester_code varchar(40),
    @courseID  int
)
AS
Begin 
Delete GradPlan_Course
from GradPlan_Course 
Join Graduation_Plan  on GradPlan_Course.plan_id = Graduation_Plan.plan_id
where student_id = @studentID AND GradPlan_Course.semester_code = @semester_code And course_id = @courseID;
END;
GO
--select * from GradPlan_Course
--Select * from Graduation_Plan
--exec Procedures_AdvisorDeleteFromGP 1,'W23',1


-- W)
--Double check
Create Proc Procedures_AdvisorApproveRejectCHRequest
(
    @RequestID int,
    @Current_semester_code varchar(40)
)
AS
Begin
if (exists(select * from Request where Request.request_id = @RequestID and Request.type= 'credit_hours'))
begin
UPDATE Request
SET status = 
    CASE 
        When S.gpa < 3.7 AND R.credit_hours <= 3 AND GP.semester_code = @Current_semester_code AND GP.semester_credit_hours < 34 THEN 'approved'
        ELSE 'rejected'
        END
from Request as R
Join Student as S On R.student_id = S.student_id 
Join Graduation_Plan as GP on GP.student_id = S.student_id
where R.request_id = @RequestID

if(SELECT status from Request WHERE request_id=@RequestID)='approved'
begin
    update I
    set I.amount = I.amount + 1000*R.credit_hours
    from Payment as P
    inner join Request R on R.student_id = P.student_id
    inner join Installment I on I.payment_id = p.payment_id
    where I.status  = 'notPaid' and I.deadline = (SELECT MIN(deadline) from  Installment where payment_id = P.payment_id);
END
END
END;
GO

--select * from Request
--select * from Graduation_Plan
--select * from Installment
--exec Procedures_AdvisorApproveRejectCHRequest 3,'S23R1'


-- V) 
go
Create FUNCTION FN_Advisors_Requests (@advisorID int)
Returns table
AS
Return(
    Select*
    From Request R
    Where R.advisor_id = @advisorID
)
go
--select * from Advisor
--select * from Request
--select * from dbo.FN_Advisors_Requests(2)


-- X)
Create Proc Procedures_AdvisorViewAssignedStudents
(
    @AdvisorID int,
    @major varchar(40)
)
AS
Begin
Select s.student_id as "Student id", s.f_name + ' ' + s.l_name as 'Student Name', s.major as 'Student major', CRS.name
From Student as s
LEFT Join Student_Instructor_Course_Take as SICT on s.student_id = SICT.student_id
LEFT Join Course as CRS on SICT.course_id = CRS.course_id
where s.major = @major AND s.advisor_id = @AdvisorID;
END
GO
--Select * from Student
--Select * from Advisor
--exec Procedures_AdvisorViewAssignedStudents 2, 'CS'


-- Y) not complete still the handling of consequences
--Double CHECK
Create Proc Procedures_AdvisorApproveRejectCourseRequest
(
    @RequestID int,
    @studentID int,
    @advisorID int
)
AS 
Begin
if (exists(select * from Request where request_id = @RequestID and type= 'course'))
begin
UPDATE Request
Set status = 
    CASE 
        WHEN S.assigned_hours > C.credit_hours AND  P.prerequisite_course_id IS NOT NULL THEN 'Approved'
        ElSE 'Rejected'
    END
From Request as R
Join Student as S on R.student_id = S.student_id
Join PreqCourse_course as P on R.course_id = P.course_id
Join Student_Instructor_Course_Take as T on R.student_id = T.student_id 
Join Course as C on R.course_id = C.course_id
Where R.student_id = @studentID AND R.request_id = @RequestID AND R.advisor_id = @AdvisorID
end
END
GO
--select * from Request
--exec Procedures_AdvisorApproveRejectCourseRequest 1,1,2


-- Z)
create PROC Procedures_AdvisorViewPendingRequests
(
    @AdvisorID int
)
AS
Begin
Select R.request_id, R.type, R.comment, R.status, R.credit_hours, R.student_id, R.course_id, R.advisor_id
From Request R
where R.advisor_id =@AdvisorID AND R.status = 'pending'
end
GO

--select * from Request
--exec Procedures_AdvisorViewPendingRequests 7


-- AA) 
-- NEEDS TESTING
Create FUNCTION FN_StudentLogin(@StudentID int, @password varchar (40))
Returns bit
AS 
Begin
Declare @success Bit 
if exists( select*
    from student s
    Where @StudentID = S.student_id And S.password = @password)
Set @success = 1
else
    set @success = 0
return @success
end
go


-- BB)
Create Proc Procedures_StudentaddMobile
(
    @StudentID int,
    @mobile_number varchar (40)
)
as
Begin 
Insert Into 
Student_Phone(student_id,phone_number)
VALUES
(@StudentID,@mobile_number)
end
Go  

--Select * from Student_Phone
--exec Procedures_StudentaddMobile 4, '123-123-9231'


-- CC)
-- DOUBLE CHECK
Create Function FN_SemsterAvailableCourses(@semster_code varchar (40))
returns table
AS
return(
    Select C.name
    From Course C 
    inner join Course_Semester CS on CS.course_id = C.course_id
    inner join Semester S on S.semester_code = CS.semester_code
    Where S.semester_code = @semster_code 
)
go

--select * from Course
--select * from Semester
--select * from dbo.FN_SemsterAvailableCourses('S23R1')


-- DD)
-- DOUBLE CHECK
Create Proc Procedures_StudentSendingCourseRequest
(
    @StudentID int,
    @CourseID int,
    @type varchar (40),
    @comment varchar (40)
    
)
as
Begin
Declare @advisorID int
Declare @CreditHours int

Select @advisorID = S.advisor_id
From Student as S
Where S.student_id = @StudentID

Select @CreditHours = C.credit_hours
From Course as C
Where C.course_id = @CourseID



insert into 
Request(type,comment,credit_hours,student_id,advisor_id,course_id)
VALUES
(@type,@comment,@CreditHours,@StudentID,@advisorID,@courseID)
end
Go

--Select * from Request
--Select * from Course
--Select * from Student
--exec Procedures_StudentSendingCourseRequest 1,2,'course','workplzzzz'


-- EE)
create Proc Procedures_StudentSendingCHRequest
(
    @StudentID int,
    @credithours int,
    @type varchar (40),
    @comment varchar (40)
)
AS
begin
Declare @advisorID int
Select @advisorID = S.advisor_id
From Student as S
Where S.student_id = @StudentID

Insert into 
Request(type,comment,credit_hours,student_id,advisor_id,course_id)
VALUES
(@type,@comment,@credithours,@studentID,@advisorID,null)
end
Go


--exec Procedures_StudentSendingCHRequest 1,3,'credit_hours','WORK PLZZZZZ'



---------MOAZZZZZZZZ
--MAZ
--PROCS AND FUNCTIONS

--FF
go
create function  FN_StudentViewGP( @studentID int)
returns table
as
return(
SELECT 
s.student_id as 'student ID' , s.f_name+' '+s.l_name as 'student_name' 
, g.plan_id as 'graduation plan Id' , gc.course_id as 'course id' , c.name as 'course name' 
,g.semester_code as 'semester code',g.expected_grad_date
, g.semester_credit_hours as 'semester credit hours' ,g.advisor_id	 as 'advisor id'

FROM gradplan_course gc INNER JOIN Graduation_plan g ON g.plan_id=gc.plan_id 
INNER JOIN student s ON s.student_id=g.student_id
INNER JOIN Course c ON c.course_id = gc.course_id
WHERE s.student_id = @studentID

)
go


--GG
go
create function FN_StudentUpcoming_installment(@StudentID int)
returns datetime
as
begin
declare @output datetime

SELECT  TOP 1 @output = i.deadline  
FROM installment i INNER JOIN payment p ON p.payment_id=i.payment_id 
WHERE p.student_id= @studentID
ORDER BY i.deadline desc

return @output
end
go


--HH
go
create function  FN_StudentViewSlo(@courseID int, @instructorID int)
returns table
as
return(
SELECT slot_id as 'slot ID' , location , time , day FROM slot WHERE course_id=@courseID AND instructor_id=@instructorID
)
go

--II
GO
CREATE PROC Procedures_StudentRegisterFirstMakeup
@studentID int,
@courseID int,
@studentcurrentsemester varchar(40)

AS
declare @examID int
SELECT @examID=exam_id from (makeup_exam m INNER JOIN Course_Semester cs ON cs.course_id=m.course_ID) 
WHERE m.type='first' AND m.course_id=@courseID AND cs.semester_code=@StudentCurrentSemester

DECLARE @eligibility bit --1 is eligable

if (

exists(SELECT * FROM student_instructor_course_take cict 
WHERE ( cict.grade='FF' OR cict.grade='F' OR cict.grade=null ) 
AND cict.student_id=@studentID AND cict.course_id=@courseID AND cict.exam_type='normal'
)

AND

NOT EXISTS( SELECT * FROM student_instructor_course_take WHERE student_id=@studentID AND course_id=@courseID 
AND (exam_type='First_makeup' OR exam_type='Second_makeup') )
)

BEGIN


SET @eligibility =1

end 

ELSE

BEGIN

SET @eligibility=0

END


if @eligibility=1
BEGIN
/*CREATE TABLE Student_Instructor_Course_Take(

student_id int not null,
course_id int not null,
instructor_id int not null,
semester_code varchar(40), --not int--
exam_type VARCHAR(40) DEFAULT 'Normal' CHECK (exam_type IN ('Normal','First_makeup', 'Second_makeup')),
grade Varchar(40) DEFAULT null,

CONSTRAINT fk_constraint9 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint10 FOREIGN KEY (course_id) REFERENCES Course (Course_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT fk_constraint11 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,
--ON DELETE CASCADE
--ON UPDATE CASCADE,

CONSTRAINT pk_constraint8 PRIMARY KEY (course_id,student_id,semester_code)

*/
insert into Student_Instructor_Course_Take(student_id,course_id,semester_code,exam_type)
values(@studentID,@courseID,@studentcurrentsemester,'First_makeup')


--Exam_Student (exam_id int,student_id int, course_id int)
insert into exam_student(exam_id,student_id,course_id) values (@examID,@studentID,@courseID)

END
GO

--jj
GO
CREATE FUNCTION FN_StudentCheckSMEligiability
(@courseId int , @studentID int)
returns bit
as
begin
DECLARE @eligibility bit --1 if true
DECLARE @failure_count int
DECLARE @first_makeup_grade varchar(40)

SELECT @failure_count=count(*) FROM student_instructor_course_take s 
WHERE (s.grade='F' OR s.grade='FF' OR s.grade='FA') AND @courseId=course_id AND @studentID=student_id

SELECT @first_makeup_grade=s.grade FROM student_instructor_course_take s  
WHERE s.exam_type='First_makeup' AND s.course_id=@courseID AND s.student_id=@studentID




if (@first_makeup_grade=null OR @first_makeup_grade='FA') AND (@failure_count <3)
BEGIN

SET @eligibility =1

END

ELSE

BEGIN

SET @eligibility=0

END

return @eligibility
end
GO

--KK
GO 
CREATE PROC Procedures_StudentRegisterSecondMakeup
@StudentID int, @courseID int, @StudentCurrentSemester Varchar (40)
AS

DECLARE @eligibility bit --1 if true
DECLARE @examID int

SELECT @examID=m.exam_id from (makeup_exam m INNER JOIN Course_Semester cs ON cs.course_id=m.course_ID)  
WHERE m.type='Second MakeUp' AND m.course_id=@courseID AND cs.semester_code=@StudentCurrentSemester

SET @eligibility = dbo.FN_StudentCheckSMEligiability( @courseID , @studentID)

if @eligibility=1

BEGIN 


insert into Student_Instructor_Course_Take(student_id,course_id,semester_code,exam_type)
values(@studentID,@courseID,@studentcurrentsemester,'Second_makeup')


--Exam_Student (exam_id int,student_id int, course_id int)
insert into exam_student(exam_id,student_id,course_id) values (@examID,@studentID,@courseID)

END
GO

--LL

--A course is considered required (according to a certain student) if it is unattended or failed (and not eligible for makeup)

/*By default, all students are eligible for first makeup. However, the student’s grade in
the normal exam should be null, ‘FF’, or ‘F’ and the student shouldn’t have taken any
makeup exam before in this course*/

GO
CREATE FUNCTION FN_makeup1_eligibility
( @studentID int,@courseID int)
returns bit
as
begin
DECLARE @eligibility bit --1 if true
DECLARE @grade varchar(40)

select @grade=grade from student_instructor_course_take 

if(@grade='F' or @grade='FF' or @grade=null)
BEGIN

SET @eligibility =1

END

ELSE

BEGIN

SET @eligibility=0

END

if(
exists(select * from student_instructor_course_take 
        where exam_type='First_makeup' or exam_type='First_makeup' AND student_id=@studentID and course_id=@courseID )
)
begin
set @eligibility=0 
end

return @eligibility
END
GO

GO
CREATE PROC  Procedures_ViewRequiredCourses
(@StudentID int, @Currentsemestercode Varchar (40)) --how to return a table 
AS
begin

SELECT s.course_id from student_instructor_course_take s

WHERE 
s.semester_code=@Currentsemestercode 
AND s.student_id=@studentID  
AND dbo.FN_makeup1_eligibility(@studentID,s.course_id)=0 
AND dbo.FN_StudentCheckSMEligiability(s.course_id,@studentID)=0 
AND (s.grade='FF' OR s.grade='FA' OR s.grade='F')
end
GO


--MM
--Optional Courses: courses from the current semester or upcoming semesters (Student is allowed to take the optional course if he/she satisfied their prerequisites).
--FAQs mentionned we must use all semester codes
GO
CREATE PROC Procedures_ViewOptionalCourse
@StudentID int, @Currentsemestercode Varchar (40)
AS

DECLARE @major varchar(40)
select @major=major from student where student_id=@studentID



SELECT c.name , c.course_id 
FROM course c INNER JOIN student_instructor_course_take sict ON c.course_id=sict.course_id
WHERE c.major=@major AND sict.semester_code=@currentsemestercode AND sict.student_id=@studentID


-- AND NOT EXIST PREQ howwa lessa ma5adoo4
AND NOT EXISTS(
SELECT *
FROM preqcourse_course pc
WHERE pc.course_id=c.course_id

EXCEPT

SELECT pc2.*
FROM preq_course_course pc2 INNER JOIN student_instructor_course_take sict ON sict.course_id=pc2.prerequisite_course_id
WHERE pc2.course_id=c.course_id
)
GO


--NN
GO
CREATE PROC Procedures_ViewMS
@studentID int
AS
declare @major varchar(40)
select @major = s.major from student s where s.student_id=@studentId
--dy kol elcourses 
select c.course_id , c.name from course c 

where not exists(
--dy elcourses el5adha 
select  course_id from student_instructor_course_take sict
where sict.student_id=@studentID
)  
AND c.major=@major 
GO


--OO
GO
CREATE PROC Procedures_ChooseInstructor
@StudentID int, @InstructorID int, @CourseID int , @current_semester_code varchar(40)
AS

UPDATE Student_Instructor_Course_Take 
Set instructor_id = @InstructorID
Where student_id = @StudentID and course_id = @CourseID 
and semester_code = @current_semester_code;
GO




-- Adding 10 records to the Course table
INSERT INTO Course(name, major, is_offered, credit_hours, semester)  VALUES
( 'Mathematics 2', 'Science', 1, 3, 2),
( 'CSEN 2', 'Engineering', 1, 4, 2),
( 'Database 1', 'MET', 1, 3, 5),
( 'Physics', 'Science', 0, 4, 1),
( 'CSEN 4', 'Engineering', 1, 3, 4),
( 'Chemistry', 'Engineering', 1, 4, 1),
( 'CSEN 3', 'Engineering', 1, 3, 3),
( 'Computer Architecture', 'MET', 0, 3, 6),
( 'Computer Organization', 'Engineering', 1, 4, 4),
( 'Database2', 'MET', 1, 3, 6);


-- Adding 10 records to the Instructor table
INSERT INTO Instructor(name, email, faculty, office) VALUES
( 'Professor Smith', 'prof.smith@example.com', 'MET', 'Office A'),
( 'Professor Johnson', 'prof.johnson@example.com', 'MET', 'Office B'),
( 'Professor Brown', 'prof.brown@example.com', 'MET', 'Office C'),
( 'Professor White', 'prof.white@example.com', 'MET', 'Office D'),
( 'Professor Taylor', 'prof.taylor@example.com', 'Mechatronics', 'Office E'),
( 'Professor Black', 'prof.black@example.com', 'Mechatronics', 'Office F'),
( 'Professor Lee', 'prof.lee@example.com', 'Mechatronics', 'Office G'),
( 'Professor Miller', 'prof.miller@example.com', 'Mechatronics', 'Office H'),
( 'Professor Davis', 'prof.davis@example.com', 'IET', 'Office I'),
( 'Professor Moore', 'prof.moore@example.com', 'IET', 'Office J');

-- Adding 10 records to the Semester table
INSERT INTO Semester(semester_code, start_date, end_date) VALUES
('W23', '2023-10-01', '2024-01-31'),
('S23', '2023-03-01', '2023-06-30'),
('S23R1', '2023-07-01', '2023-07-31'),
('S23R2', '2023-08-01', '2023-08-31'),
('W24', '2024-10-01', '2025-01-31'),
('S24', '2024-03-01', '2024-06-30'),
('S24R1', '2024-07-01', '2024-07-31'),
('S24R2', '2024-08-01', '2024-08-31')

-- Adding 10 records to the Advisor table
INSERT INTO Advisor(name, email, office, password) VALUES
( 'Dr. Anderson', 'anderson@example.com', 'Office A', 'password1'),
( 'Prof. Baker', 'baker@example.com', 'Office B', 'password2'),
( 'Dr. Carter', 'carter@example.com', 'Office C', 'password3'),
( 'Prof. Davis', 'davis@example.com', 'Office D', 'password4'),
( 'Dr. Evans', 'evans@example.com', 'Office E', 'password5'),
( 'Prof. Foster', 'foster@example.com', 'Office F', 'password6'),
( 'Dr. Green', 'green@example.com', 'Office G', 'password7'),
( 'Prof. Harris', 'harris@example.com', 'Office H', 'password8'),
( 'Dr. Irving', 'irving@example.com', 'Office I', 'password9'),
( 'Prof. Johnson', 'johnson@example.com', 'Office J', 'password10');

-- Adding 10 records to the Student table
INSERT INTO Student (f_name, l_name, gpa, faculty, email, major, password, financial_status, semester, acquired_hours, assigned_hours, advisor_id)   VALUES 
( 'John', 'Doe', 3.5, 'Engineering', 'john.doe@example.com', 'CS', 'password123', 1, 1, 90, 30, 1),
( 'Jane', 'Smith', 3.8, 'Engineering', 'jane.smith@example.com', 'CS', 'password456', 1, 2, 85, 34, 2),
( 'Mike', 'Johnson', 3.2, 'Engineering', 'mike.johnson@example.com', 'CS', 'password789', 1, 3, 75, 34, 3),
( 'Emily', 'White', 3.9, 'Engineering', 'emily.white@example.com', 'CS', 'passwordabc', 0, 4, 95, 34, 4),
( 'David', 'Lee', 3.4, 'Engineering', 'david.lee@example.com', 'IET', 'passworddef', 1, 5, 80, 34, 5),
( 'Grace', 'Brown', 3.7, 'Engineering', 'grace.brown@example.com', 'IET', 'passwordghi', 0, 6, 88, 34, 6),
( 'Robert', 'Miller', 3.1, 'Engineerings', 'robert.miller@example.com', 'IET', 'passwordjkl', 1, 7, 78, 34, 7),
( 'Sophie', 'Clark', 3.6, 'Engineering', 'sophie.clark@example.com', 'Mechatronics', 'passwordmno', 1, 8, 92, 34, 8),
( 'Daniel', 'Wilson', 3.3, 'Engineering', 'daniel.wilson@example.com', 'DMET', 'passwordpqr', 1, 9, 87, 34, 9),
( 'Olivia', 'Anderson', 3.7, 'Engineeringe', 'olivia.anderson@example.com', 'Mechatronics', 'passwordstu', 0, 10, 89, 34, 10);


-- Adding 10 records to the Student_Phone table
INSERT INTO Student_Phone(student_id, phone_number) VALUES
(4, '456-789-0123'),
(5, '567-890-1234'),
(6, '678-901-2345'),
(7, '789-012-3456'),
(8, '890-123-4567'),
(9, '901-234-5678'),
(10, '012-345-6789');


-- Adding 10 records to the PreqCourse_course table
INSERT INTO PreqCourse_course(prerequisite_course_id, course_id) VALUES
(2, 7),
(3, 10),
(2, 4),
(5, 6),
(4, 7),
(6, 8),
(7, 9),
(9, 10),
(9, 1),
(10, 3);


-- Adding 10 records to the Instructor_Course table
INSERT INTO Instructor_Course (instructor_id, course_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);


-- Adding 10 records to the Student_Instructor_Course_Take table
INSERT INTO Student_Instructor_Course_Take (student_id, course_id, instructor_id, semester_code,exam_type, grade) VALUES
(1, 1, 1, 'W23', 'Normal', 'A'),
(2, 2, 2, 'S23', 'First_makeup', 'B'),
(3, 3, 3, 'S23R1', 'Second_makeup', 'C'),
(4, 4, 4, 'S23R2', 'Normal', 'B+'),
(5, 5, 5, 'W23', 'Normal', 'A-'),
(6, 6, 6, 'W24', 'First_makeup', 'B'),
(7, 7, 7, 'S24', 'Second_makeup', 'C+'),
(8, 8, 8, 'S24R1', 'Normal', 'A+'),
(9, 9, 9, 'S24R2', 'Normal', 'FF'),
(10, 10, 10, 'S24', 'First_makeup', 'B-');



-- Adding 10 records to the Course_Semester table
INSERT INTO Course_Semester (course_id, semester_code) VALUES
(1, 'W23'),
(2, 'S23'),
(3, 'S23R1'),
(4, 'S23R2'),
(5, 'W23'),
(6, 'W24'),
(7, 'S24'),
(8, 'S24R1'),
(9, 'S24R2'),
(10, 'S24');

-- Adding 10 records to the Slot table
INSERT INTO Slot (day, time, location, course_id, instructor_id) VALUES
( 'Monday', 'First', 'Room A', 1, 1),
( 'Tuesday', 'First', 'Room B', 2, 2),
( 'Wednesday', 'Third', 'Room C', 3, 3),
( 'Thursday', 'Fifth', 'Room D', 4, 4),
( 'Saturday', 'Second', 'Room E', 5, 5),
( 'Monday', 'Fourth', 'Room F', 6, 6),
( 'Tuesday', 'Second', 'Room G', 7, 7),
( 'Wednesday', 'Fifth', 'Room H', 8, 8),
( 'Thursday', 'First', 'Room I', 9, 9),
( 'Sunday', 'Fourth', 'Room J', 10, 10);


-- Adding 10 records to the Graduation_Plan table
INSERT INTO Graduation_Plan (semester_code, semester_credit_hours, expected_grad_date, student_id, advisor_id) VALUES
( 'W23', 90,    '2024-01-31' ,   1, 1),
( 'S23', 85,    '2025-01-31'  ,     2, 2),
( 'S23R1', 75,  '2025-06-30' ,  3, 3),
( 'S23R2', 95,  '2024-06-30' , 4, 4),
( 'W23', 80,    '2026-01-31'   ,  5, 5),
( 'W24', 88,    '2024-06-30'   ,    6, 6),
( 'S24', 78,    '2024-06-30'    ,  7, 7),
( 'S24R1', 92,  '2025-01-31'  , 8, 8),
( 'S24R2', 87,  '2024-06-30'    ,  9, 9),
( 'S24', 89,    '2025-01-31'    ,    10, 10);

-- Adding 10 records to the GradPlan_Course table
INSERT INTO GradPlan_Course(plan_id, semester_code, course_id) VALUES
(1, 'W23', 1),
(2, 'S23', 2),
(3, 'S23R1', 3),
(4, 'S23R2', 4),
(5, 'W23', 5),
(6, 'W24', 6),
(7, 'S24', 7),
(8, 'S24R1', 8),
(9, 'S24R2', 9),
(10, 'S24', 10);

-- Adding 10 records to the Request table
INSERT INTO Request (type, comment, status, credit_hours, course_id, student_id, advisor_id) VALUES 
( 'course', 'Request for additional course', 'pending', null, 1, 1, 2),
( 'course', 'Need to change course', 'approved', null, 2, 2, 2),
( 'credit_hours', 'Request for extra credit hours', 'pending', 3, null, 3, 3),
( 'credit_hours', 'Request for reduced credit hours', 'approved', 1, null, 4, 5),
( 'course', 'Request for special course', 'rejected', null, 5, 5, 5),
( 'credit_hours', 'Request for extra credit hours', 'pending', 4, null, 6, 7),
( 'course', 'Request for course withdrawal', 'approved', null, 7, 7, 7),
( 'course', 'Request for course addition', 'rejected', null, 8, 8, 8),
( 'credit_hours', 'Request for reduced credit hours', 'approved', 2, null, 9, 8),
( 'course', 'Request for course substitution', 'pending', null, 10, 10, 10);

-- Adding 10 records to the MakeUp_Exam table
INSERT INTO MakeUp_Exam (date, type, course_id) VALUES
('2023-02-10', 'First MakeUp', 1),
('2023-02-15', 'First MakeUp', 2),
('2023-02-05', 'First MakeUp', 3),
('2023-02-25', 'First MakeUp', 4),
('2023-02-05', 'First MakeUp', 5),
('2024-09-10', 'Second MakeUp', 6),
('2024-09-20', 'Second MakeUp', 7),
('2024-09-05', 'Second MakeUp', 8),
('2024-09-10', 'Second MakeUp', 9),
( '2024-09-15', 'Second MakeUp', 10);

-- Adding 10 records to the Exam_Student table
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 1, 1);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 2, 2);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 3, 3);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 2, 4);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 3, 5);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 4, 6);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 3, 7);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 4, 8);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 5, 9);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (4, 4, 10);

-- Adding 10 records to the Payment table
INSERT INTO Payment (amount, start_date,n_installments, status, fund_percentage, student_id, semester_code, deadline)  VALUES
( 500, '2023-11-22', 1, 'notPaid', 50.00, 1, 'W23', '2023-12-22'),
( 700, '2023-11-23', 1, 'notPaid', 60.00, 2, 'S23', '2023-12-23'),
( 600, '2023-11-24', 4, 'notPaid', 40.00, 3, 'S23R1', '2024-03-24'),
( 800, '2023-11-25', 1, 'notPaid', 70.00, 4, 'S23R2', '2023-12-25'),
( 550, '2023-11-26', 5, 'notPaid', 45.00, 5, 'W23', '2024-04-26'),
( 900, '2023-11-27', 1, 'notPaid', 80.00, 6, 'W24', '2023-12-27'),
( 750, '2023-10-28', 2, 'Paid', 65.00, 7, 'S24', '2023-12-28'),
( 620, '2023-08-29', 4, 'Paid', 55.00, 8, 'S24R1', '2023-12-29'),
( 720, '2023-11-30', 2, 'notPaid', 75.00, 9, 'S24R2', '2024-01-30'),
( 580, '2023-11-30', 1, 'Paid', 47.00, 10, 'S24', '2023-12-31');



-- Adding 10 records to the Installment table
INSERT INTO Installment (payment_id, start_date, amount, status, deadline) VALUES
(1, '2023-11-22', 50, 'notPaid','2023-12-22'),
(2, '2023-11-23', 70, 'notPaid','2023-12-23'),
(3, '2023-12-24', 60, 'notPaid','2024-01-24'),
( 4,'2023-11-25', 80, 'notPaid','2023-12-25'),
(5, '2024-2-26', 55, 'notPaid','2024-3-26'),
( 6,'2023-11-27', 90, 'notPaid','2023-12-06'),
(7, '2023-10-28', 75, 'Paid','2023-11-28'),
( 7,'2023-11-28', 62, 'Paid','2023-12-28'),
( 9,'2023-12-30', 72, 'notPaid','2024-01-30'),
( 10,'2023-11-30', 58, 'Paid','2023-12-30');



-- Executions
--2.1 
--2
Exec CreateAllTables
--3
Exec DropAllTables
--4
Exec clearAllTables

--2.2
--A
Select * from view_Students
--B
Select * from view_Course_prerequisites
--C
Select * from Instructors_AssignedCourses
--D
Select * from Student_Payment
--E
Select * from Courses_Slots_Instructor
--F
Select * from Courses_MakeupExams
--G
Select * from Students_Courses_transcript
--H
Select * from Semster_offered_Courses
--I
Select * from Advisors_Graduation_Plan


--2.3 
-- A
Declare @stud_id int
Exec Procedures_StudentRegistration 'John', 'Doe', 'password123', 'Engineering',
'jane.smith@example.com', 'CS', 1, @stud_id output 
Print @stud_id --id of first insertion in student table
--B
Declare @adv_id int
Exec Procedures_AdvisorRegistration 'Dr. Anderson','password1' , 'anderson@example.com',
'Office A', @adv_id output --output the  id of the first insertion in table advisor 
Print @adv_id
--C
Exec Procedures_AdminListStudents--lists all advising students
--D
Exec Procedures_AdminListAdvisors -- lists all advisors
--E 
Exec AdminListStudentsWithAdvisors --lists all students with their advisors
--F
Exec AdminAddingSemester '2024-09-20', '2025-03-15', 'W25' -- inserts this semester 
-- G 
Exec Procedures_AdminAddingCourse 'BI', 4, 2, 'csen501', 1   --inserts this new course
-- H
Exec Procedures_AdminLinkInstructor 1, 1, 1 --inserts this record in slots but thi (this has a problem)
-----
-- I
Exec Procedures_AdminLinkStudent  2 , 8, 7 ,'W22' --deeh hat3ml moshkela
--J 
Exec Procedures_AdminLinkStudentToAdvisor 2,4
--K
Exec Procedures_AdminAddExam 'First MakeUp', '2025-10-19', 5
--L
Exec Procedures_AdminIssueInstallment 4
--M
Exec Procedures_AdminDeleteCourse 2
--N
Exec Procedure_AdminUpdateStudentStatus 9
--O
Select * from all_Pending_Requests
--P
Exec Procedures_AdminDeleteSlots 'W23'

--Q
DECLARE @qsuccessbit bit
SET @qsuccessbit =dbo.FN_AdvisorLogin(1, 'password15')
Print @qsuccessbit

--R 
Exec Procedures_AdvisorCreateGP 'W23', '2026-08-18', 20, 4,7

--S all of the insertions have insufficient ch for this one
Exec Procedures_AdvisorAddCourseGP 4, 'S24', 'CSEN301' 





--maz excutions
select * from dbo.FN_StudentViewGP --FF

--GG
declare @tmp1 datetime
set @tmp1=dbo.FN_StudentUpcoming_installment


select * from dbo.FN_StudentViewSlot --HH


exec Procedures_StudentRegisterFirstMakeup 1 ,1 ,'W23' --II register for 1st makeup

--JJ
declare @tmp2 bit
set @tmp2=dbo.FN_StudentCheckSMEligiability

exec Procedures_StudentRegisterSecondMakeup 1, 1, 'W23' --KK register for 2nd makeup

exec Procedures_ViewRequiredCourses 1 ,'W23' --LL view required courses

exec Procedures_ViewOptionalCourse 1 ,'W23' --MM optional courses of this student 

exec Procedures_ViewMS 1 --NN n4oof missing courses of student 1

exec Procedures_ChooseInstructor 1 ,2, 1, 'W23' --OO elmfrood nla2yh 8ayyar elinstructor id to 2 


exec Procedures_AdvisorUpdateGP 1,'2024-01-30' 
exec Procedures_AdvisorDeleteFromGP 1,'W23',1
exec Procedures_AdvisorApproveRejectCHRequest 3,'S23R1'
select * from dbo.FN_Advisors_Requests(2)
exec Procedures_AdvisorViewAssignedStudents 2, 'CS'
exec Procedures_AdvisorApproveRejectCourseRequest 1,1,2
exec Procedures_AdvisorViewPendingRequests 7
exec Procedures_StudentaddMobile 4, '123-123-9231'
select * from dbo.FN_SemsterAvailableCourses('S23R1')
exec Procedures_StudentSendingCourseRequest 1,2,'course','workplzzzz'

exec Procedures_StudentSendingCHRequest 1,3,'credit_hours','WORK PLZZZZZ'