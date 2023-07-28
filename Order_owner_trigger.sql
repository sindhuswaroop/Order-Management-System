-- Trigger to monitor Order Descp Events

create or replace trigger bt_order_desc
before insert or delete or update on order_desc
for each row
enable
declare
    v_user varchar(20);
begin
    select user into v_user from dual;
    if inserting then
        dbms_output.put_line ('You have inserted the record in Order Description' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Order Description' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Order Description' || v_user);
    end if;
end;
/



-- Trigger to monitor Order Payment History Events

create or replace trigger bt_order_payment_history
before insert or delete or update on order_payment_history
for each row
enable
declare
    v_user varchar(20);
begin
    select user into v_user from dual;
    if inserting then
        dbms_output.put_line ('You have inserted the record in Order Payment History' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Order Payment History' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Order Payment History' || v_user);
    end if;
end;
/



-- Trigger to monitor Order Item Detail Table Events

create or replace trigger bt_order_item_details
before insert or delete or update on order_item_details
for each row
enable
declare
    v_user varchar(20);
begin
    select user into v_user from dual;
    if inserting then
        dbms_output.put_line ('You have inserted the record in Order Item Details' || v_user);
    elsif deleting then
        dbms_output.put_line  ('You have deleted the record in Order Item Details' || v_user);
    elsif updating then
        dbms_output.put_line ('You have updated the record in Order Item Details' || v_user);
    end if;
end;
/



create or replace TRIGGER log_order_item_details
  AFTER INSERT on order_item_details
  FOR EACH ROW
BEGIN
    dbms_output.put_line ('You have updated the record in Order Item Details');
  --INSERT INTO order_item_details_log values(user_id, Log_date, Action);
  --VALUES (:NEW.user_id, SYSDATE, :NEW.order_item_id, 'User inserted a record');
END;
