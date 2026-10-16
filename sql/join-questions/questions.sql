-- Customers with valid email format and cities starting with M

select * from customers
where Email regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
and City regexp '^M';
;

select * from customers;
select * from orders;

select * from customers
 left Join orders
 using(customer_ID)
 where Order_ID is null
 ;