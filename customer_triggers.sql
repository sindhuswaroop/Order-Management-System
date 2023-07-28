set serveroutput on;

-- Trigger to monitor Customer Table Events

create or replace trigger bt_customer
before insert or delete or update on customer
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
        dbms_output.put_line ('You have inserted the record in Customer Table' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Customer Table' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Customer Table' || v_user);
    end if;
end;
/
-- Trigger to monitor Customer Address Events

create or replace trigger bt_customer_address
before insert or delete or update on customer_address
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
        dbms_output.put_line ('You have inserted the record in Customer Address' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Customer Address' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Customer Address' || v_user);
    end if;
end;
/

