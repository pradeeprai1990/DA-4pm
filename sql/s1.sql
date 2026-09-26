-- CREATE DATABASE company;

-- CREATE DATABASE ecomApp;

-- use company;
-- use ecom;

use company;

CREATE TABLE employee(
		empID INT primary key auto_increment,
        empName varchar(30) not null,
        empEmail varchar(30),
        empPhone  varchar (30),
        empAddress text
);

-- alter table employee rename employees;

-- alter table employees modify column empEmail varchar(50) unique;

alter table employees rename column empAddress to empAdd;

INSERT into employee value(
	1,
	'Ravi Ws',
    "ravi@gmail.com",
    "+915353454",
    "Jodhpur Ws"
);


insert into employee 
(empName,empEmail,empPhone,empAddress)
values("Prince Ws","Prince@ws.com","+6567556567","ws jaipur");

insert into employee set empName="raj",empEmail="raj@ws.com",
empPhone='+67675675';


select * from employee;


