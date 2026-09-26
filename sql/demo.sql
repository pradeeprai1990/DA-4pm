Create database school;

use school;

create table student(
	studentID Int primary key auto_increment,
    studentName varchar(30),
    studentClass varchar(30) null null,
    studentAddress text

);

drop database school;

alter table student rename students;
alter table students add column studentGender varchar(10);
alter table students rename column studentGender to stuGender;
alter table students modify column  stuGender varchar(30) not null;
alter table students add column stdStatus tinyint default(1);
truncate table students;
truncate table students;



 
