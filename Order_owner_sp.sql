-- stored procedure and functions sql file for Order_Owner 
-- run this file as Order_Owner user

set serveroutput on;

create or replace function orderowner_checkItemQuantity(in_item_id item_owner.item.item_id%TYPE)
return varchar
is
v_qty int;
begin
    select i1.item_quantity into v_qty from item_owner.item_inventory i1 where i1.item_id = in_item_id;
    return v_qty;
end;
/

create or replace function convertToType(in_amount varchar2)
return varchar
is
begin
    if in_amount = 1 then
        return 'credit_card';
    elsif in_amount = 2 then
        return 'debit_card';
    elsif in_amount = 3 then
        return 'gift_card';
    end if;
end;
/

create or replace procedure order_insert(in_customer_id customer_owner.customer.customer_id%TYPE, 
                                         in_shipping_address_id customer_owner.customer_address.address_id%TYPE,
                                         in_billing_address_id customer_owner.customer_address.address_id%TYPE,
                                         in_items in varchar2,
                                         in_payment_type in varchar2, 
                                         in_payment_amount in varchar2)
is
v_cust int;
v_cust_status int;
v_invalid_item int;
v_present_order_id int;
v_item_status int;
v_invalid_billing int;
v_invalid_shipping int;
v_individual_item_id number;
v_amount_to_be_paid number;
v_final_amount_paid number;

e_invalid_payment_amount exception;
e_invalid_payment_type exception;
e_item_status exception;
e_invalid_item exception;
e_cust_not_found exception;
e_cust_inactive exception;
e_item_out_of_stock exception;
e_invalid_billing exception;
e_invalid_shipping exception;
begin

    
    select count(*) into v_cust from customer_owner.customer c1 where c1.customer_id = in_customer_id;
    if v_cust = 0 then
        raise e_cust_not_found;
    end if;
    
    select c1.status into v_cust_status from customer_owner.customer c1 where c1.customer_id = in_customer_id;
    if v_cust_status = 0 then
        raise e_cust_inactive;
    end if;
    
    select count(*) into v_invalid_billing from customer_owner.customer_address where address_id = in_billing_address_id;
    if v_invalid_billing = 0 then
        raise e_invalid_billing;
    end if;
    
    select count(*) into v_invalid_shipping from customer_owner.customer_address where address_id = in_shipping_address_id;
    if v_invalid_shipping = 0 then
        raise e_invalid_shipping;
    end if; 
    
    --dbms_output.put_line('Reached point 1, '|| orderowner_checkItemQuantity(20));
    
    insert into order_owner.order_desc (order_creation_timestamp, customer_id, order_status, order_return_flag, shipping_address_id)
                    values (systimestamp, in_customer_id, 1, 0, in_shipping_address_id);
    
    select t1.order_id into v_present_order_id from (select order_id, customer_id, order_creation_timestamp, dense_rank() over (order by order_creation_timestamp desc) rank_1 
    from order_desc where order_return_flag = 0 and customer_id = in_customer_id) t1 where t1.rank_1 = 1;
    
    v_amount_to_be_paid := 0;
    
    for c in (select * from (select to_number(regexp_substr(in_items, '[^,]+', 1, level)) as item_id
              from dual
              connect by level <= regexp_count(in_items, ',') + 1))
        loop
            select count(*) into v_item_status from item_owner.item where item_id = c.item_id and item_status = 0;
            if v_item_status > 0 then 
                raise e_item_status;
            end if;
            if orderowner_checkItemQuantity(c.item_id) = 0 then
                dbms_output.put_line(c.item_id||' is out of stock, please remove all items out of stock from order before placing it');
                raise e_item_out_of_stock;
            else
                --dbms_output.put_line('Insert will be done');
                begin
                    insert into order_owner.order_item_details (item_id, order_id, inventory_update_status, is_item_returned, record_create_timestamp)
                                values(c.item_id, v_present_order_id, 1, 0, systimestamp);
                    --update inventory
                    update ITEM_OWNER.item_inventory set inventory_update_timestamp = systimestamp,
                    item_quantity = - 1 + (select item_quantity from ITEM_OWNER.item_inventory where item_id = c.item_id) where item_id = c.item_id;

                    dbms_output.put_line('Item '|| c.item_id ||' has been added to order.');
                    select item_price into v_individual_item_id from item_owner.item where item_id = c.item_id;
                    v_amount_to_be_paid := v_amount_to_be_paid + v_individual_item_id;
                end;
            end if;
        end loop;

    
    -- Handling payments
    
    --final amount to be paid is:
    
    dbms_output.put_line('Amount to be paid is: '|| v_amount_to_be_paid);
    
    for c in (select to_number(regexp_substr(in_payment_type, '[^,]+', 1, level)) as g_payment_type, to_number(regexp_substr(in_payment_amount, '[^,]+', 1, level)) as g_payment_amount from dual
              connect by level <= regexp_count(in_payment_type, ',') + 1 and level <= regexp_count(in_payment_amount, ',') + 1)
        loop
            if c.g_payment_type not in (1,2,3) then raise e_invalid_payment_type; end if;
            
            if c.g_payment_amount is null then raise e_invalid_payment_amount; end if;
            
            begin
                insert into order_owner.order_payment_history(order_id, payment_status, record_create_timestamp, payment_type, amount_received, billing_address_id)
                values (v_present_order_id, 1, systimestamp, convertToType(c.g_payment_type), c.g_payment_amount, in_billing_address_id); 
            end;
            dbms_output.put_line(c.g_payment_type||' is payment type and amount is ' ||c.g_payment_amount);
        end loop;
        
    select max(abs(cdf_sum)) into v_final_amount_paid from (select t1.*, sum(amount_received) over (order by token_id) as cdf_sum from order_payment_history t1 where order_id = v_present_order_id);
    
    if v_amount_to_be_paid != v_final_amount_paid then
        raise e_invalid_payment_amount;
    end if;
    
    update order_owner.order_desc set total_amount_usd = v_final_amount_paid where order_id = v_present_order_id;
    commit;
    dbms_output.put_line('Your order has been created with order_id: '|| v_present_order_id);
    
exception
    when e_invalid_billing
        then dbms_output.put_line('Invalid billing ID entered, not found at our end. Please add/update address or use correct billing_address_id');
        rollback;
    when e_invalid_shipping
        then dbms_output.put_line('Invalid shipping ID entered, not found at our end. Please add/update address or use correct shipping_address_id');
        rollback;
    when e_invalid_payment_amount
        then dbms_output.put_line('Invalid payment amount entered [enter float/double], or values not summing up to correct amount. Please check!');
        rollback;
    when e_invalid_payment_type 
        then dbms_output.put_line('Invalid payment type entered, please enter 1 for Credit Card, 2 for Debit Card, and 3 for Gift Card only.');
        rollback;
    when e_item_status 
        then dbms_output.put_line('One or more items are not for sale, sorry');
        rollback;
    when e_invalid_item
        then dbms_output.put_line('Invalid Item ID entered, or some other exception occured. Order not created. Please check all data thouroughly and enter correctly');
        rollback;
    when e_cust_not_found 
        then dbms_output.put_line('Customer not found, please enter valid customer ID');
        rollback;
    when e_cust_inactive
        then dbms_output.put_line('Customer inactive, please activate your account before placing order');
        rollback;
    when e_item_out_of_stock 
        then dbms_output.put_line('Please try again by inserting only in-stock items');
        rollback;
    when others then dbms_output.put_line('Unknown error! Please contact ADMINISTRATOR!');
        rollback;
end;
/

grant execute on order_owner.order_insert to customer_owner;
/* steps for order_insert SP: (customer_id, shipping_address_id, billing_address_id, 'item_id1, item_id2, etc..', 
payment_type[enter 1 for Credit Card, 2 for Debit Card, and 3 for Gift Card] = ('1,2,3'), payment_amount = '66.99, 77.99') */




--order return

create or replace procedure order_return(in_customer_id order_owner.order_desc.customer_id%TYPE,
                                         in_order_id order_owner.order_desc.order_id%TYPE, 
                                         in_item_id item_owner.item.item_id%TYPE)
is
v_didCustPurchase int;
v_orderExists int;
v_orderItemAlreadyReturned int;
v_isItemPartOfOrder int;
v_amt_refunded float;

e_didCustPurchase exception;
e_orderDoesNotExist exception;
e_orderItemAlreadyReturned exception;
e_isItemPartOfOrder exception;
begin
    select count(*) into v_didCustPurchase from order_owner.order_desc t1 where t1.order_id = in_order_id and t1.customer_id = in_customer_id;
    if v_didCustPurchase = 0 then
        raise e_didCustPurchase;
    end if;
    
    select count(*) into v_orderExists from order_owner.order_desc t1 where t1.order_id = in_order_id;
    if v_orderExists = 0 then
        raise e_orderDoesNotExist;
    end if;
    
    select count(*) into v_isItemPartOfOrder from order_owner.order_item_details t1 where t1.order_id = in_order_id and t1.item_id = in_item_id;
    if v_isItemPartOfOrder = 0 then
        raise e_isItemPartOfOrder;
    end if;
    
    select is_item_returned into v_orderItemAlreadyReturned from (select DENSE_RANK() OVER (ORDER BY t1.is_item_returned asc, record_update_timestamp desc)
    as rank_1, is_item_returned from order_item_details t1 where order_id = in_order_id and item_id = in_item_id) where rank_1 = 1;
    if v_orderItemAlreadyReturned != 0 then
        raise e_orderItemAlreadyReturned;
    end if;
    
    dbms_output.put_line('Item order combo can be returned');
    dbms_output.put_line('Item_Id '||in_item_id||' from order_id '||in_order_id||' will be returned.');

    
    --dbms_lock.sleep(10);
    
    begin
        -- Order Desc
        insert into order_owner.order_desc(order_creation_timestamp, customer_id, order_status, order_return_flag, shipping_address_id, orig_order_id) 
        values(systimestamp, in_customer_id, 1, 1, (select shipping_address_id from order_owner.order_desc where order_id = in_order_id), in_order_id);
    
        -- Order Payment Hist
        select item_price into v_amt_refunded from ITEM_OWNER.item where item_id = in_item_id;
        insert into order_owner.order_payment_history(order_id, payment_status, record_create_timestamp, payment_type, amount_received, billing_address_id)
        values ((select order_id from (select order_id, order_creation_timestamp, dense_rank() over(order by order_creation_timestamp desc) rank_1 from order_desc) t1 where t1.rank_1 = 1),
                1, systimestamp, 'OrigRefund', -1*v_amt_refunded, (select billing_address_id from (select billing_address_id, dense_rank() over (order by record_create_timestamp desc) as rank_1 from order_payment_history where order_id = in_order_id) where rank_1 = 1));
        
        update order_owner.order_desc set order_status = 5, order_update_timestamp = systimestamp,
            total_amount_usd = -1*v_amt_refunded where order_id = (
            select order_id from (select order_id, order_creation_timestamp, dense_rank() over(order by order_creation_timestamp desc) rank_1 
            from order_desc where customer_id = in_customer_id) t1 where t1.rank_1 = 1);

        -- Order Item Return
        update order_owner.order_item_details set is_item_returned = 1, record_update_timestamp = systimestamp where 
        order_item_id = (
            select order_item_id from (select order_item_id, item_id, order_id, DENSE_RANK() OVER (ORDER BY order_item_id DESC) as rank_1
            from order_item_details where order_id = in_order_id and item_id = in_item_id and is_item_returned = 0) where rank_1 = 1);
        
        -- Update inventory
        update ITEM_OWNER.item_inventory set inventory_update_timestamp = systimestamp,
        item_quantity = 1 + (select item_quantity from ITEM_OWNER.item_inventory where item_id = in_item_id) where item_id = in_item_id;
        
                
        commit;
    exception when others then
    rollback;
    raise;
    end;
    
    dbms_output.put_line('Returned and Refunded');
    
exception
    when e_didCustPurchase then dbms_output.put_line('Given customer did not purchase order, please check'); rollback;
    when e_orderDoesNotExist then dbms_output.put_line('Incorrect order number/ID entered, please check'); rollback;
    when e_orderItemAlreadyReturned then dbms_output.put_line('This order/item combo has already been returned by you, sorry!'); rollback;
    when e_isItemPartOfOrder then dbms_output.put_line('Given item not part of the order, please check'); rollback;
    --when others then dbms_output.put_line('Unknown error! Please contact ADMINISTRATOR! Transaction not commited!'); rollback;
end;
/

grant execute on order_owner.order_return to customer_owner;
/* order_return(customer_id, order_id, item_id) */


-- Order update by back-end store user/delivery man

create or replace procedure order_update(in_order_id order_owner.order_desc.order_id%TYPE, in_order_status order_owner.order_desc.order_status%TYPE)
is
v_isValidOrder number;
v_presentStatus order_owner.order_desc.order_status%TYPE;

e_isValidOrder exception;
e_invalidStatusCode exception;
begin
    select count(*) into v_isValidOrder from order_owner.order_desc where order_id = in_order_id;
    if v_isValidOrder = 0 then
        raise e_isValidOrder;
    end if;
    
    if in_order_status not in (1,2,3,4,5,6) then
        raise e_invalidStatusCode;
    end if;
    
    update order_owner.order_desc set order_status = in_order_status, order_update_timestamp = systimestamp
    where order_id = in_order_id;
    commit;
    
    dbms_output.put_line('The order '||in_order_id||' status has been changed to '||in_order_status);
    
exception
when e_isValidOrder then dbms_output.put_line('Order not found in database system'); rollback;
when e_invalidStatusCode then dbms_output.put_line('Invalid code entered - please enter 1 for Order Placed, 2 for Order Shipped,
 3 for Order Out for Delivery, 4 for Order Fulfilled/Delivered, 5 for Order Returned/Cancelled'); rollback;
end;
/

-- exec order_update(order_id, order_status);
