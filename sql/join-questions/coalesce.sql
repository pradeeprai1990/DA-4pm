use data_cleaning_practice;

select * from customers;

SELECT 
     COALESCE(customer_name, 'Unkown') AS email,
    COALESCE(email, 'No Email') AS email
FROM customers;


SELECT 
    customer_name,
    NULLIF(credit_limit, '0') AS credit_limit
FROM customers;


