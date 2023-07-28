set serveroutput on;

/* 

ALL QUERIES SUCCESSFULLY RUN IN ORDER_OWNER

*/

-- Checking to see if there is a specific payment type that is higher and used more than others
select unique(payment_type), 
round(avg(total_amount_usd), 2) as "Average Order Price",
count(payment_type) as "Total Number of Orders"
from order_owner.order_desc_item_payment_view 
group by payment_type 
order by payment_type;

-- Checking to see which customer id paid the greatest amount for products
select unique(customer_id), round(avg(total_amount_usd), 2) as "Total Amount Paid"
from order_owner.order_desc_item_customer_view
group by customer_id
order by round(avg(total_amount_usd), 2) desc;

-- Checking to see which months had the greatest net profit and the greatest number of orders
-- This is not created from a view because the business may be interested in seeing when the greatest number of orders are placed
select to_char(order_creation_timestamp, 'YYYY-MM') as "Creation Date", 
sum(total_amount_usd) as "Total Amount Spent", 
count(order_creation_timestamp) as "Number of Orders"
from order_owner.order_desc
group by to_char(order_creation_timestamp, 'YYYY-MM')
order by 1;

-- Checking to see which items were bought most frequently -- these items may need to be restocked more frequently 
select i.item_id as "Item ID", i.item_name as "Item Name", count(oid.item_id) as "Total Orders"
from item_owner.item i
join order_owner.order_item_details oid
on i.item_id = oid.item_id
group by i.item_id, i.item_name
order by 3 desc;

-- Checking to see the total amount of returns 
select sum(total_amount_usd) as "Total Amount of Returns"
from order_owner.order_desc
where order_return_flag = 1;

-- Checking to see the total amount of revenue (sum of all purchases and returns)
select sum(total_amount_usd) as "Total Revenue"
from order_owner.order_desc_item_customer_view;


-- Checking to see the list of customers who are frequent buyers
select * from (
select c.first_name as Customer_Name, o.customer_id, count(o.customer_id) as frequent_buyers
from order_owner.order_desc o
join customer_owner.customer c
on o.customer_id = c.customer_id
where order_status = 1
group by c.first_name, o.customer_id
order by frequent_buyers desc )
where rownum <= 10;


-- Checking to understand which customers are returning orders more frequently
select * from 
(select c.first_name, o.customer_id, count(o.customer_id) as returns_count 
from order_owner.order_desc o
join customer_owner.customer c
on o.customer_id = c.customer_id
where o.order_return_flag = 1
group by c.first_name, o.customer_id
order by returns_count desc )
where rownum <= 5;


-- Checking to understand which areas in MA maximum orders coming from
select * from
( select c.address_line1, c.zip, count(o.customer_id) as Max_orders
from CUSTOMER_OWNER.customer_address c
join order_owner.order_desc o
on c.customer_id = o.customer_id
where o.order_status = 1
group by c.address_line1, c.zip
order by Max_orders desc )
where rownum <= 10;


-- Checking to get the trend in buying based on hour of the day (military time)
select extract(Hour from order_creation_timestamp) as Order_traffic_time,
count(order_id) as Num_Orders
from order_owner.order_desc
where order_status = 1
group by extract(Hour from order_creation_timestamp)
order by num_orders desc;



