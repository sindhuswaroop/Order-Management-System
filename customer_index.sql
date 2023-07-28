set serveroutput on;

-- run file in customer_owner schema

declare
v_cnt number;
begin
    select count(*) into v_cnt from all_indexes where lower(index_name) = 'customer_contact_idx';
    if v_cnt = 0 then
        execute immediate ('create index customer_contact_idx on customer_owner.customer(first_name, last_name, phone_number, email)');
        dbms_output.put_line('Index created.');
    else
        dbms_output.put_line('Index exists.');
    end if;
end;
/
