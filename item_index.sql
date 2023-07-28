set serveroutput on;

-- run file in order_owner schema

declare
v_cnt number;
begin
    select count(*) into v_cnt from all_indexes where lower(index_name) = 'item_idx';
    if v_cnt = 0 then
        execute immediate ('create index item_idx on item_owner.item(item_name, item_price)');
        dbms_output.put_line('Index created.');
    else
        dbms_output.put_line('Index exists.');
    end if;
end;
/
