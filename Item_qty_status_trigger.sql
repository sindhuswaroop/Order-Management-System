-- Trigger to update the item status if quantity is 0

/*
Create or replace trigger Item_quantity_status_trigger 
After UPDATE Of item_quantity ON item_inventory
FOR EACH ROW
Begin
    update 
    (Select item.item_status, item_inventory.item_quantity
    from item
    left join item_inventory
    on item.item_id = item_inventory.item_id 
    where item_inventory.item_quantity = 0) a
    set a.item_status = 0;
End; */

Create or replace trigger Item_quantity_status_trigger 
After UPDATE on item_inventory
declare
v_item_qty number;
begin
    select item_quantity into v_item_qty from (select item_quantity,inventory_update_timestamp, dense_rank() 
        over (order by inventory_update_timestamp desc) as rank_1 from item_inventory) where rank_1 = 1;
    
    if v_item_qty = 0 then
        update item set item_status = 0, item_update_timestamp = systimestamp where item_id = 
        (select item_id from (select item_id, inventory_update_timestamp, dense_rank() 
        over (order by inventory_update_timestamp desc) as rank_1 from item_inventory) where rank_1 = 1 );
    end if;
end;
/



  