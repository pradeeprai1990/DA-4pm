SELECT e1.*, e2.firstName as managerName  FROM employees e1 
left join employees e2 
on e1.reportsTo=e2.employeeNumber;
with totolRev as (
	select sum(o.Quantity*p.Price) as totolRev
	from orders o join products p using(product_id)
	where o.Status!="cancelled"
) 
select c.Customer_Name,sum(o.Quantity*p.Price) as customerRev from customers c
join orders o using(Customer_ID)
join products p using(product_id)
where o.Status!="cancelled"
group by c.Customer_Name
having customerRev>
(
  select totolRev from totolRev 
)*0.005
;


with avgTable as (
select avg(Price) as avgValue from products 
)
select * from products
where Price>
(
select avgValue from avgTable)*1.5
;


SELECT 
    p.Product_ID,
    p.Product_Name,
    COUNT(o.Product_ID) AS Order_Frequency
FROM products p
JOIN orders o 
    ON p.Product_ID = o.Product_ID
GROUP BY 
    p.Product_ID,
    p.Product_Name
having Order_Frequency>
(
select avg(count) from(
select Product_ID,count(*)as count from orders
group by Product_ID) as productOrder
);
