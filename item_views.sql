/*
Item_View: Consists of the following columns: item.item_name, item.item_description, 
item.item_price, and item_inventory.item_quantity for customers to access the items 
and their details.
*/ 

create or replace view item_view as 
    select i.item_name, i.item_description, i.item_price, ii.item_quantity
    from item_owner.item i
        join item_owner.item_inventory ii
            on i.item_id = ii.item_id;

/*
Item_Reviews_View: Consists of the following columns: item_reviews.item_id, 
item.item_name, item.item_description, item_reviews.review_desc, item_reviews.customer_id, 
customer.first_name, item_reviews.review_rating for customers to access the reviews 
of different items.
*/


create or replace view item_reviews_view as 
    select ir.item_id, 
    i.item_name, i.item_description, ir.review_desc, ir.customer_id, 
    c.first_name, ir.review_rating
    from item_owner.item_reviews ir 
        join item_owner.item i 
            on ir.item_id = i.item_id
        join customer_owner.customer c
            on ir.customer_id = c.customer_id;
