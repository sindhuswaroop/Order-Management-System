/*
Customer_View: Consists of the following columns: customer.first_name, customer.last_name, 
customer_address.address_line1, customer_address.address_line2, customer_address.city, 
customer_address.zip, customer_address.state, customer.phone_number, customer.email will 
display’s customers demographic information that can be accessed and modified by the customer.
*/

create or replace view customer_view as 
    select c.first_name, c.last_name, 
    ca.address_line1, ca.address_line2, ca.city, 
    ca.zip, ca.state_name, c.phone_number, c.email
    from customer_owner.customer c
        join customer_owner.customer_address ca
            on c.customer_id = ca.customer_id;
            
