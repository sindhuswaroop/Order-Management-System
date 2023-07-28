-- This file will contain all of the grants and privileges created by the DBA account.

set serveroutput on;

declare
v_cnt number;
begin
    select count(*) into v_cnt from all_users where lower(username) = 'customer_owner';
    if v_cnt = 0 then
        execute immediate ('create user customer_owner identified by Customerowner2022');
        dbms_output.put_line('User customer_owner created.');
    else
        dbms_output.put_line('User customer_owner exists.');
    end if;
end;
/

declare
v_cnt number;
begin
    select count(*) into v_cnt from all_users where lower(username) = 'item_owner';
    if v_cnt = 0 then
        execute immediate ('create user item_owner identified by Itemowner2022');
        dbms_output.put_line('User item_owner created.');
    else
        dbms_output.put_line('User item_owner exists.');
    end if;
end;
/

declare
v_cnt number;
begin
    select count(*) into v_cnt from all_users where lower(username) = 'order_owner';
    if v_cnt = 0 then
        execute immediate ('create user order_owner identified by Orderowner2022');
        dbms_output.put_line('User order_owner created.');
    else
        dbms_output.put_line('User order_owner exists.');
    end if;
end;
/

-- Access Management
-- grant create session
grant create session to item_owner, order_owner, customer_owner;

-- grant create objects
grant create table to item_owner, order_owner, customer_owner;
grant create procedure to item_owner, order_owner, customer_owner;
--grant create function to item_owner, order_owner, customer_owner;

--grant all privileges to item_owner, order_owner, customer_owner; 
grant unlimited tablespace to item_owner, order_owner, customer_owner; 
grant create sequence to item_owner, order_owner, customer_owner; 
grant create view to item_owner, order_owner, customer_owner; 


grant connect to item_owner, order_owner, customer_owner;

--SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'ADMIN' and granted_role like upper('%dba%');

--drop user item_owner cascade;
--drop user order_owner cascade;
--drop user customer_owner cascade;

--grant grant create trigger to item_owner, order_owner, customer_owner;
grant create trigger to item_owner, order_owner, customer_owner;

commit;
