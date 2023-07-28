--This file should be run by item_owner_user

set serveroutput on;
        
--INSERT NEW ITEM

create or replace procedure item_insert(in_item_name item.item_name%TYPE, 
                                        in_item_description item.item_description%TYPE,
                                        in_item_price item.item_price%TYPE,
                                        in_item_group item.item_group%TYPE) is
v_item_name number;
v_item_description number;
v_item_id item.item_id%TYPE;

e_wrongInputs exception;
e_itemExists exception;
e_itemnametoolong exception;
e_itemdescriptiontoolong exception;

begin
    if length(in_item_name) >200 then
        raise e_itemnametoolong;
    end if;
        
    if length(in_item_description) >500 then
        raise e_itemdescriptiontoolong;
    end if;
    
    if length(in_item_name) is null or length(in_item_description) is null or 
        length(in_item_price) is null or length(in_item_group) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_item_name from item where lower(item_name) = lower(in_item_name);
    
    if(v_item_name!=0) then
        select count(*) into v_item_description from item where lower(item_description) = lower(in_item_description) and lower(item_name) = lower(in_item_name);
        if(v_item_description!=0) then
            raise e_itemExists;
        end if;
    end if;

    insert into item (item_name, item_description, item_price, item_group) values 
                    (in_item_name, in_item_description, in_item_price, abs(in_item_group));
    select item_id into v_item_id from item where lower(item_name) = lower(in_item_name) and lower(item_description) = lower(in_item_description);
    insert into item_inventory (item_id, item_group) values (v_item_id, abs(in_item_group));
    dbms_output.put_line('Item added successfully.');
    commit; 
    
    exception
        when e_itemExists then dbms_output.put_line('Item already exists in the database. Insert unsuccessful.');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. All fields are required.');
        when e_itemnametoolong then dbms_output.put_line('Item name too long. Please enter a description of maximum 200 characters.');
        when e_itemdescriptiontoolong then dbms_output.put_line('Item description too long. Please enter a description of maximum 500 characters.');
        
        rollback;
end;
/
/*steps for item_insert SP: exec item_insert('item_name', 'item_description', item_price, item_group)*/


--UPDATE ITEM NAME/DESCRIPTION/PRICE/GROUP

create or replace procedure item_update(in_item_id item.item_name%TYPE, 
                                        in_item_name item.item_name%TYPE, 
                                        in_item_description item.item_description%TYPE,
                                        in_item_price item.item_price%TYPE,
                                        in_item_group item.item_group%TYPE,
                                        in_item_status item.item_status%TYPE)
is
v_item_id number;
v_item_status item.item_status%TYPE;

e_itemidreqd exception;
e_wrongInputs exception;
e_itemNotFound exception;
e_itemnametoolong exception;
e_itemdescriptiontoolong exception;
e_invalidStatus exception;
e_alreadySellable exception;
e_alreadyNotSellable exception;

begin
    if length(in_item_id) is null then 
        raise e_itemidreqd;
    end if;
    
    if length(in_item_name) is null and length(in_item_description) is null and
        length(in_item_price) is null and length(in_item_group) is null and
        length(in_item_status) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_item_id from item where item_id = in_item_id;
    if(v_item_id=0) then
        raise e_itemNotFound;
    end if;
    
    if length(in_item_name) >200 then
        raise e_itemnametoolong;
    end if;
        
    if length(in_item_description) >500 then
        raise e_itemdescriptiontoolong;
    end if;
    
    if in_item_status not in (0,1) then
        raise e_invalidStatus;
    end if;
    
    if length(in_item_name) is not null then
        update item set item_name = in_item_name, item_update_timestamp = systimestamp where item_id = in_item_id;
        dbms_output.put_line('Item name has been changed.');
        commit;
    end if;
        
    if length(in_item_description) is not null then
        update item set item_description = in_item_description, item_update_timestamp = systimestamp where item_id = in_item_id;
        dbms_output.put_line('Item description has been changed.');
        commit;
    end if;
    
    if length(in_item_price) is not null then
        update item set item_price = in_item_price, item_update_timestamp = systimestamp where item_id = in_item_id;
        dbms_output.put_line('Item price has been changed.');
        commit;
    end if;
    
    if length(in_item_group) is not null then
        update item set item_group = in_item_group, item_update_timestamp = systimestamp where item_id = in_item_id;
        update item_inventory set item_group = in_item_group, inventory_update_timestamp = systimestamp where item_id = in_item_id;
        dbms_output.put_line('Item group has been changed.');
        commit;
    end if;
    
    select item_status into v_item_status from item where item_id = in_item_id;
    
    if length(in_item_status) is not null then
        if in_item_status = 1 then
            if (v_item_status = 1) then
                raise e_alreadySellable;
            else
                update item set item_status = in_item_status, item_update_timestamp = systimestamp where item_id = in_item_id;
                dbms_output.put_line('Item status changed to Sellable');
                commit;
            end if;
        elsif in_item_status = 0 then
            if (v_item_status = 0) then
                raise e_alreadyNotSellable;
            else
                update item set item_status = in_item_status, item_update_timestamp = systimestamp where item_id = in_item_id;
                dbms_output.put_line('Item status changed to Not Sellable');
                commit;        
            end if;
        end if;
    end if;
    
    exception 
        when e_itemidreqd then dbms_output.put_line('Item ID is a required field.');
        when e_wrongInputs then dbms_output.put_line('At least one field is required.');
        when e_itemNotFound then dbms_output.put_line('Item ID not found or invalid.');
        when e_itemnametoolong then dbms_output.put_line('Item name too long. Please enter a description of maximum 200 characters.');
        when e_itemdescriptiontoolong then dbms_output.put_line('Item description too long. Please enter a description of maximum 500 characters.');
        when e_invalidStatus then dbms_output.put_line('Item Status can only be 0 or 1.');
        when e_alreadySellable then dbms_output.put_line('Item already Sellable.');
        when e_alreadyNotSellable then dbms_output.put_line('Item already Not Sellable.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/
/*steps for item_update SP: exec item_update(item_id, 'item_name', 'item_description', item_price, item_group, item_status)*/

--UPDATE ITEM QUANTITY IN INVENTORY TABLE

create or replace procedure item_inventory_update(in_item_id item_inventory.item_id%TYPE, 
                                        in_item_quantity item_inventory.item_quantity%TYPE)
is
v_item_id number;

e_wrongInputs exception;
e_itemNotFound exception;

begin
    
    if length(in_item_id) is null or length(in_item_quantity) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_item_id from item where item_id = in_item_id;
    if(v_item_id=0) then
        raise e_itemNotFound;
    end if;
    
    update item_inventory set item_quantity = abs(in_item_quantity), inventory_update_timestamp = systimestamp where item_id = in_item_id;
    dbms_output.put_line('Item quantity has been changed.');
    commit;

    exception 
        when e_wrongInputs then dbms_output.put_line('Both fields are required.');
        when e_itemNotFound then dbms_output.put_line('Item ID not found or invalid.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

/*steps for item_inventory_update SP: exec item_inventory_update(item_id, item_qty)*/

--INSERT NEW ITEM REVIEW

create or replace procedure item_review_insert(in_customer_id item_reviews.customer_id%TYPE, 
                                        in_item_id item_reviews.item_id%TYPE,
                                        in_review_desc item_reviews.review_desc%TYPE,
                                        in_review_rating item_reviews.review_rating%TYPE) is
v_item_id number;
v_cust_id number;
v_cust_review number;
v_item_review number;
v_purchase_flag number;
v_review_id item_reviews.review_id%TYPE;

e_wrongInputs exception;
e_itemNotFound exception;
e_custNotFound exception;
e_itemreviewtoolong exception;
e_reviewExists exception;
e_invalidRating exception;

begin
    if length(in_customer_id) is null or length(in_item_id) is null or length(in_review_rating) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_item_id from item where item_id = in_item_id;
    if(v_item_id=0) then
        raise e_itemNotFound;
    end if;
    
    select count(*) into v_cust_id from customer_owner.customer where customer_id = in_customer_id;
    if(v_cust_id=0) then
        raise e_custNotFound;
    end if;
    
    select count(*) into v_cust_review from item_reviews where customer_id = in_customer_id;
    if(v_cust_review!=0) then
        select count(*) into v_item_review from item_reviews where customer_id = in_customer_id and item_id = in_item_id;
        if(v_item_review!=0) then
            raise e_reviewExists;
        end if;
    end if;
    
    if length(in_review_desc) >2000 then
        raise e_itemreviewtoolong;
    end if;
    
    if in_review_rating >5 or in_review_rating <1 then
        raise e_invalidRating;
    end if;
    
    insert into item_reviews (customer_id, item_id, review_desc, review_rating) values 
                    (in_customer_id, in_item_id, in_review_desc, in_review_rating);
    dbms_output.put_line('Item review added successfully.');
    select review_id into v_review_id from item_reviews where customer_id = in_customer_id and item_id=in_item_id;
    
    select count(item_id) into v_purchase_flag from order_owner.order_item_details where order_id in 
    (select order_id from order_owner.order_desc where customer_id = in_customer_id) and item_id = in_item_id;
    
    if(v_purchase_flag=0) then
        update item_reviews set customer_purchase_item_flag = 0 where review_id = v_review_id;
    else
        update item_reviews set customer_purchase_item_flag = 1 where review_id = v_review_id;
    end if;
    commit; 
    
    exception
        when e_itemNotFound then dbms_output.put_line('No such item exists.');
        when e_custNotFound then dbms_output.put_line('No such customer exists.');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. Customer ID, Item ID and Review Rating fields are required.');
        when e_itemreviewtoolong then dbms_output.put_line('Item review too long. Please enter a description of maximum 2000 characters.');
        when e_reviewExists then dbms_output.put_line('You have already reviewed this item. You can edit your review if you wish.');
        when e_invalidRating then dbms_output.put_line('Review rating must be 1 to 5.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

grant execute on item_review_insert to customer_owner;
/*steps for item_review_insert SP: exec item_review_insert(customer_id, item_id, 'review_desc', review_rating)*/

--UPDATE ITEM REVIEW

create or replace procedure item_review_update(in_review_id item_reviews.review_id%TYPE, 
                                        in_review_desc item_reviews.review_desc%TYPE,
                                        in_review_rating item_reviews.review_rating%TYPE) is
v_review_id number;

e_reviewidreqd exception;
e_wrongInputs exception;
e_reviewNotFound exception;
e_itemreviewtoolong exception;
e_invalidRating exception;

begin
    if length(in_review_id) is null then
        raise e_reviewidreqd;
    end if;
    
    if length(in_review_desc) is null and length(in_review_rating) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_review_id from item_reviews where review_id = in_review_id;
    if(v_review_id=0) then
        raise e_reviewNotFound;
    end if;
    
    if length(in_review_desc) >2000 then
        raise e_itemreviewtoolong;
    end if;
    
    if in_review_rating >5 or in_review_rating <1 then
        raise e_invalidRating;
    end if;
    
    if length(in_review_desc) is not null then
        update item_reviews set review_desc = in_review_desc where review_id = in_review_id;
        commit; 
        dbms_output.put_line('Item review updated successfully.');
    end if;
    
    if length(in_review_rating) is not null then
        update item_reviews set review_rating = in_review_rating where review_id = in_review_id;
        commit; 
        dbms_output.put_line('Item rating updated successfully.');
    end if;
    
    exception
        when e_reviewidreqd then dbms_output.put_line('Review ID is a required field.');
        when e_reviewNotFound then dbms_output.put_line('Invalid Review ID.');
        when e_wrongInputs then dbms_output.put_line('At least one of the two fields - Review Description or Review Rating are required.');
        when e_itemreviewtoolong then dbms_output.put_line('Item review too long. Please enter a description of maximum 2000 characters.');
        when e_invalidRating then dbms_output.put_line('Review rating must be 1 to 5.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

grant execute on item_review_update to customer_owner;
/*steps for item_review_update SP: exec item_review_update(review_id, 'review_desc', review_rating)*/

--DELETE ITEM REVIEW

create or replace procedure item_review_delete(in_review_id item_reviews.review_id%TYPE) is
v_review_id number;

e_reviewidreqd exception;
e_reviewNotFound exception;

begin
    if length(in_review_id) is null then
        raise e_reviewidreqd;
    end if;
    
    select count(*) into v_review_id from item_reviews where review_id = in_review_id;
    if(v_review_id=0) then
        raise e_reviewNotFound;
    end if;
    
    delete from item_reviews where review_id = in_review_id;
    dbms_output.put_line('Item review deleted successfully.');
    commit;
    
    exception
        when e_reviewidreqd then dbms_output.put_line('Review ID is a required field.');
        when e_reviewNotFound then dbms_output.put_line('Invalid Review ID.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

grant execute on item_review_delete to customer_owner;
/*steps for item_review_delete SP: exec item_review_delete(review_id)*/
