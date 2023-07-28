-- Run this test-case file as customer_owner user

exec ORDER_OWNER.order_insert(100, 1, 1, '25', '1', '24.99');
exec ORDER_OWNER.order_insert(100, 1, 1, '25', '1', '299.98');

/* steps for order_insert SP: (customer_id, shipping_address_id, billing_address_id, 'item_id1, item_id2, etc..', 
payment_type[enter 1 for Credit Card, 2 for Debit Card, and 3 for Gift Card] = ('1,2,3'), payment_amount = '66.99, 77.99') */


exec ORDER_OWNER.order_return(100, 115, 24);
exec ORDER_OWNER.order_return(100, 115, 25);

/* steps for order_return SP: (customer_id, order_id, item_id) */