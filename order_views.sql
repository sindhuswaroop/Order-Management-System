/*
Order_Desc_Item_Payment_View: This view will consist of three tables: Order_Item_Details, 
Order_Desc, and Order_Payment_history. It will consist of the following columns: 
order_desc.order_id, order_payment_history.payment_status, order_desc.order_status, 
order_desc.total_amount_usd, order_payment_history.payment_type, order_item_details.item_id 
to help the customers to keep track of every transaction.
*/

create or replace view Order_Desc_Item_Payment_View as
    select od.order_id, oph.payment_status, od.order_status, 
            od.total_amount_usd, oph.payment_type, oid.item_id
    from order_owner.order_desc od 
        join order_owner.order_payment_history oph
            on od.order_id = oph.order_id 
        join order_owner.order_item_details oid
            on od.order_id = oid.order_id;

/*
Order_Desc_Item_Customer_View: This view will consist of three tables: 
Order_Item_Details, Order_Desc, and Customer. It will have the following columns: 
order_desc.order_id, order_desc.customer_id, customer.first_name, customer.last_name, 
order_desc.order_status, order_desc.total_amount_usd, and order_item_details.item_id, 
item.item_name.
*/

create or replace view Order_Desc_Item_Customer_View as
    select od.order_id, od.customer_id, c.first_name, c.last_name, 
        od.order_status, od.total_amount_usd, oid.item_id, 
        i.item_name
    from order_owner.order_desc od 
        join order_owner.order_item_details oid 
            on od.order_id = oid.order_id
        join item_owner.item i
            on oid.item_id = i.item_id
        join customer_owner.customer c
            on od.customer_id = c.customer_id;
    
