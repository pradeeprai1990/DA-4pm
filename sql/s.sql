create database school;

use school;

create table student(
	studentID int primary key auto_increment,
    studentName varchar(30) not null,
    studentEmail varchar(30) not null unique,
    studentPhone varchar(20)

);


alter table student rename students;
alter table student add column studentAddress text; 
alter table students modify studentPhone varchar(30) unique;
alter table students rename column studentAddress to student_Address;

insert into student ( studentName,studentEmail,studentPhone,studentAddress)
value( "test","test@ws.com","+91566666","ws jaipur" );



insert into student 
( studentName,studentEmail,studentPhone,studentAddress)
values
( "pradeep","pradeep@ws.com","+4646464","ws jaipur" ),
( "prince","prince@ws.com","+456456456","ws jodhpur" );


select * from student;

select studentID as Id ,studentName as sName from students;

delete from student  where  studentID=4;


-- truncate table students; 
-- Value Delete
-- drop table students;

-- drop database company;
