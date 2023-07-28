set serveroutput on;

-- Trigger to monitor Item Table Events

create or replace trigger bt_item
before insert or delete or update on item
for each row
enable
declare
    v_user varchar(20);
    time_db TIMESTAMP;
begin
    select user into v_user from dual;
    SELECT systimestamp into time_db FROM dual;
    DBMS_OUTPUT.PUT_LINE('time before trigger ' || time_db);
    if inserting then
        dbms_output.put_line ('You have inserted the record in Item Table' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Item Table' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Item Table' || v_user);
    end if;
end;
/


-- Trigger to monitor Item Reviews Events

create or replace trigger bt_item_reviews
before insert or delete or update on item_reviews
for each row
enable
declare
    v_user varchar(20);
    time_db TIMESTAMP;
begin
    select user into v_user from dual;
    SELECT systimestamp into time_db FROM dual;
    DBMS_OUTPUT.PUT_LINE('time before trigger ' || time_db);
    if inserting then
        dbms_output.put_line ('You have inserted the record in Item Reviews' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Item Reviews' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Item Reviews' || v_user);
    end if;
end;
/


-- Trigger to monitor Item Inventory Table Events

create or replace trigger bt_item_inventory
before insert or delete or update on item_inventory
for each row
enable
declare
    v_user varchar(20);
    time_db TIMESTAMP;
begin
    select user into v_user from dual;
    SELECT systimestamp into time_db FROM dual;
    DBMS_OUTPUT.PUT_LINE('time before trigger ' || time_db);
    if inserting then
        dbms_output.put_line ('You have inserted the record in Item Inventory' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Item Inventory' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Item Inventory' || v_user);
    end if;
end;
/





