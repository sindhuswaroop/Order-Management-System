--This file should be run by customer_owner_user

set serveroutput on;
        
--INSERT NEW CUSTOMER

create or replace procedure cust_insert(in_first_name customer.first_name%TYPE, 
                                        in_last_name customer.last_name%TYPE,
                                        in_date_of_birth customer.date_of_birth%TYPE,
                                        in_phone_number customer.phone_number%TYPE,
                                        in_email customer.email%TYPE,
                                        in_pass_hash customer.pass_hash%TYPE) is
v_phone_number number;
v_email number;

e_phoneNumberExists exception;
e_emailExists exception;
e_invalidPhoneNumber exception;
e_invalidEmail exception;
e_wrongInputs exception;
e_futureDOB exception;

begin
    if length(in_first_name) is null or length(in_last_name) is null or 
        length(in_phone_number) is null or length(in_email) is null or 
        length(in_pass_hash) is null then
        raise e_wrongInputs;
    end if;
    
    if length(in_phone_number) <10 or length(in_phone_number) >10 then
        raise e_invalidPhoneNumber;
    end if;
    
    if in_email like '%@.%' or in_email not like '%@%.%' then
        raise e_invalidEmail;
    end if;
    
    select count(*) into v_email from customer where upper(email) = upper(in_email);
    select count(*) into v_phone_number from customer where phone_number = in_phone_number;
    
    if(v_phone_number!=0) then
        raise e_phoneNumberExists;
    end if;
    
    if(v_email!=0) then
        raise e_emailExists;
    end if;
    
    if to_date(in_date_of_birth)>systimestamp then
        raise e_futureDOB;
    end if;
    
    insert into customer (first_name, last_name, date_of_birth, phone_number, email, pass_hash) values 
                    (in_first_name, in_last_name, in_date_of_birth, in_phone_number, in_email, standard_hash(in_pass_hash, 'SHA512'));
    dbms_output.put_line('Customer added successfully.');
    commit; 
    
    exception
        when e_phoneNumberExists then dbms_output.put_line('Phone number already in use. Insert unsuccessful.');
        when e_emailExists then dbms_output.put_line('Email already in use. Insert unsuccessful.');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. All fields are required.');
        when e_invalidPhoneNumber then dbms_output.put_line('Phone number must be 10 digits.');
        when e_invalidEmail then dbms_output.put_line('Email must be in the format abc@xyz.com/edu/org.');
        when e_futureDOB then dbms_output.put_line('Date of Birth cannot be in the future.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/
/*steps for cust_insert SP: exec cust_insert('first_name', 'last_name', 'DOB in format DD-MMM-YY/YYYY', phone_number, 'email', 'password')*/

-- UPDATE CUSTOMER DETAILS

create or replace procedure cust_update(in_customer_id customer.customer_id%TYPE, 
                                        in_first_name customer.first_name%TYPE, 
                                        in_last_name customer.last_name%TYPE,
                                        in_date_of_birth customer.date_of_birth%TYPE,
                                        in_phone_number customer.phone_number%TYPE,
                                        in_email customer.email%TYPE) is
v_cust_id number;
v_phone_number number;
v_email number;

e_customeridreqd exception;
e_custNotFound exception;
e_phoneNumberExists exception;
e_emailExists exception;
e_invalidPhoneNumber exception;
e_invalidEmail exception;
e_wrongInputs exception;
e_futureDOB exception;

begin
    if length(in_customer_id) is null then
        raise e_customeridreqd;
    end if;
    
    if length(in_first_name) is null and length(in_last_name) is null and
        length(in_date_of_birth) is null and length(in_phone_number) is null and
        length(in_email) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_cust_id from customer where customer_id = in_customer_id;
    if(v_cust_id=0) then
        raise e_custNotFound;
    end if;
    
    if length(in_phone_number) <10 or length(in_phone_number) >10 then
        raise e_invalidPhoneNumber;
    end if;
    
    if in_email like '%@.%' or in_email not like '%@%.%' then
        raise e_invalidEmail;
    end if;
    
    select count(*) into v_email from customer where upper(email) = upper(in_email);
    select count(*) into v_phone_number from customer where phone_number = in_phone_number;
    
    if(v_phone_number!=0) then
        raise e_phoneNumberExists;
    end if;
    
    if(v_email!=0) then
        raise e_emailExists;
    end if;
    
    if to_date(in_date_of_birth)>systimestamp then
        raise e_futureDOB;
    end if;
    
    if length(in_first_name) is not null then
        update customer set first_name = in_first_name where customer_id = in_customer_id;
        commit; 
        dbms_output.put_line('First name updated successfully.');
    end if;
    
    if length(in_last_name) is not null then
        update customer set last_name = in_last_name where customer_id = in_customer_id;
        commit; 
        dbms_output.put_line('Last name updated successfully.');
    end if;
    
     if length(in_date_of_birth) is not null then
        update customer set date_of_birth = in_date_of_birth where customer_id = in_customer_id;
        commit; 
        dbms_output.put_line('DOB name updated successfully.');
    end if;
    
    if length(in_phone_number) is not null then
        update customer set phone_number = in_phone_number where customer_id = in_customer_id;
        commit; 
        dbms_output.put_line('Phone number updated successfully.');
    end if;
    
    if length(in_email) is not null then
        update customer set email = in_email where customer_id = in_customer_id;
        commit; 
        dbms_output.put_line('Email updated successfully.');
    end if;
    
    
    exception
        when e_phoneNumberExists then dbms_output.put_line('Phone number already in use. Update unsuccessful.');
        when e_emailExists then dbms_output.put_line('Email already in use. Update unsuccessful.');
        when e_customeridreqd then dbms_output.put_line('Customer ID is a required field.');
        when e_custNotFound then dbms_output.put_line('Invalid Customer ID.');
        when e_wrongInputs then dbms_output.put_line('At least one of the fields is required.');
        when e_invalidPhoneNumber then dbms_output.put_line('Phone number must be 10 digits.');
        when e_invalidEmail then dbms_output.put_line('Email must be in the format abc@xyz.com/edu/org.');
        when e_futureDOB then dbms_output.put_line('Date of Birth cannot be in the future.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

/*steps for cust_update SP: exec cust_update(customer_id, 'first_name', 'last_name', 'DOB in format DD-MMM-YY/YYYY', phone_number, 'email', 'password')*/


--UPDATE CUSTOMER STATUS

create or replace procedure cust_activate_deactivate(in_customer_id customer.customer_id%TYPE, in_decision varchar)
is
v_customer_id number;
v_customer_status customer.status%TYPE;

e_custNotFound exception;
e_alreadyActive exception;
e_alreadyInactive exception;
e_invalidDecision exception;
e_wrongInputs exception;

begin
    if length(in_customer_id) is null or length(in_decision) is null then
        raise e_wrongInputs;
    end if;
        
    select count(*) into v_customer_id from customer where customer_id = in_customer_id;
    
    if(v_customer_id=0) then
        raise e_custNotFound;
    end if;
    
    if upper(in_decision) not in ('ACTIVATE', 'DEACTIVATE') then
        raise e_invalidDecision;
    end if;
    
    select status into v_customer_status from customer where customer_id = in_customer_id;
    
    if upper(in_decision) = 'ACTIVATE' then
        if (v_customer_status = 1) then
            raise e_alreadyActive;
        else
            update customer set status = 1, update_timestamp = systimestamp where customer_id = in_customer_id;
            dbms_output.put_line('Customer status changed to active');
            commit;
        end if;
    elsif upper(in_decision) = 'DEACTIVATE' then
        if (v_customer_status = 0) then
            raise e_alreadyInactive;
        else
            update customer set status = 0, update_timestamp = systimestamp where customer_id = in_customer_id;
            dbms_output.put_line('Customer status changed to inactive.');
            commit;
        end if;
    end if;
    
    exception 
        when e_custNotFound then dbms_output.put_line('Customer ID not found or invalid.');
        when e_alreadyActive then dbms_output.put_line('Customer already Active.');
        when e_alreadyInactive then dbms_output.put_line('Customer already Inactive.');
        when e_invalidDecision then dbms_output.put_line('Decision must be ACTIVATE/DEACTIVATE.');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. All fields are required.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

/*steps for cust_activate_deactivate SP: exec cust_activate_deactivate(customer_id, 'decision(activate/deactivate)')*/

--UPDATE CUSTOMER PASSWORD

create or replace procedure cust_password_update(in_customer_id customer.customer_id%TYPE, in_pass_hash customer.pass_hash%TYPE)
is
v_customer_id number;
v_customer_status customer.status%TYPE;

e_custNotFound exception;
e_Inactive exception;
e_wrongInputs exception;

begin

    if length(in_customer_id) is null or length(in_pass_hash) is null then
            raise e_wrongInputs;
    end if;
    
    select count(*) into v_customer_id from customer where customer_id = in_customer_id;
    if(v_customer_id = 0) then
        raise e_custNotFound;
    end if;
    
    select status into v_customer_status from customer where customer_id = in_customer_id;
    if v_customer_status = 0 then
        raise e_Inactive;
    end if;
    
    update customer set pass_hash = standard_hash(in_pass_hash, 'SHA512'), update_timestamp = systimestamp where customer_id = in_customer_id;
    dbms_output.put_line('Password has been updated!');
    commit;
    
    exception 
        when e_custNotFound then dbms_output.put_line('Customer ID not found or invalid');
        when e_Inactive then dbms_output.put_line('Customer is inactive, please activate account to reset password');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. All fields are required.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/
/*steps for cust_password_update SP: exec cust_password_update(customer_id, 'password')*/

-- INSERT NEW CUSTOMER ADDRESS

create or replace procedure cust_address_insert(in_customer_id customer_address.customer_id%TYPE, 
                                        in_address_type customer_address.address_type%TYPE,
                                        in_address_line1 customer_address.address_line1%TYPE,
                                        in_address_line2 customer_address.address_line2%TYPE,
                                        in_city customer_address.city%TYPE,
                                        in_state_name customer_address.state_name%TYPE,
                                        in_zip customer_address.zip%TYPE) is
v_customer_id number;

e_wrongInputs exception;
e_custNotFound exception;
e_invalidAddressType exception;
e_invalidStateName exception;
e_invalidZip exception;

begin
    if length(in_customer_id) is null or length(in_address_type) is null or 
        length(in_address_line1) is null or length(in_city) is null or 
        length(in_state_name) is null or length(in_zip) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_customer_id from customer where customer_id = in_customer_id;
    if(v_customer_id = 0) then
        raise e_custNotFound;
    end if;
    
    if upper(in_address_type) not in ('BILLING', 'SHIPPING') then
        raise e_invalidAddressType;
    end if;
    
    if in_state_name not in ('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 
                    'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 
                    'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY') then
        raise e_invalidStateName;
    end if;
    
    if length(in_zip) !=5 then
        raise e_invalidZip;
    end if;
    
    insert into customer_address (customer_id, address_type, address_line1, address_line2, city, state_name, zip) values 
                (in_customer_id, in_address_type, in_address_line1, in_address_line2, in_city, in_state_name, in_zip);
    dbms_output.put_line('Customer Address added successfully.');
    commit; 

    exception
        when e_custNotFound then dbms_output.put_line('Customer ID not found or invalid.');
        when e_invalidAddressType then dbms_output.put_line('Address Type must be BILLING/SHIPPING.');
        when e_wrongInputs then dbms_output.put_line('Null inputs are not allowed. All fields are required.');
        when e_invalidStateName then dbms_output.put_line('Invalid State Name.');
        when e_invalidZip then dbms_output.put_line('ZIP must be 5 digits.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

/*steps for cust_address_insert SP: exec cust_address_insert(customer_id, 'address_type'(billing/shipping), 'address_line1', 'address_line2', 'city', 
'state_name'(2 letter state code), 'zip')*/

-- UPDATE CUSTOMER ADDRESS

create or replace procedure cust_address_update(in_customer_address_id customer_address.address_id%TYPE, 
                                        in_address_type customer_address.address_type%TYPE,
                                        in_address_line1 customer_address.address_line1%TYPE,
                                        in_address_line2 customer_address.address_line2%TYPE,
                                        in_city customer_address.city%TYPE,
                                        in_state_name customer_address.state_name%TYPE,
                                        in_zip customer_address.zip%TYPE) is
v_custaddress_id number;

e_customeraddressidreqd exception;
e_wrongInputs exception;
e_custAddressNotFound exception;
e_invalidAddressType exception;
e_invalidStateName exception;
e_invalidZip exception;

begin
    if length(in_customer_address_id) is null then
        raise e_customeraddressidreqd;
    end if;
    
    if length(in_address_type) is null and length(in_address_line1) is null and
        length(in_city) is null and length(in_address_line2) is null and
        length(in_state_name) is null and length(in_zip) is null then
        raise e_wrongInputs;
    end if;
    
    select count(*) into v_custaddress_id from customer_address where address_id = in_customer_address_id;
    if(v_custaddress_id=0) then
        raise e_custAddressNotFound;
    end if;
    
    if upper(in_address_type) not in ('BILLING', 'SHIPPING') then
        raise e_invalidAddressType;
    end if;
    
    if in_state_name not in ('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 
                    'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 
                    'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY') then
        raise e_invalidStateName;
    end if;
    
    if length(in_zip) !=5 then
        raise e_invalidZip;
    end if;
    
    if length(in_address_type) is not null then
        update customer_address set address_type = in_address_type where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('Item review updated successfully.');
    end if;
    
    if length(in_address_line1) is not null then
        update customer_address set address_line1 = in_address_line1 where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('Customer Address Line 1 updated successfully.');
    end if;
    
     if length(in_address_line2) is not null then
        update customer_address set address_line2 = in_address_line2 where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('Customer Address Line 2 updated successfully.');
    end if;
    
    if length(in_city) is not null then
        update customer_address set city = in_city where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('City updated successfully.');
    end if;
    
     if length(in_state_name) is not null then
        update customer_address set state_name = in_state_name where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('State name updated successfully.');
    end if;
    
     if length(in_zip) is not null then
        update customer_address set zip = in_zip where address_id = in_customer_address_id;
        commit; 
        dbms_output.put_line('Zip updated successfully.');
    end if;
    
    exception
        when e_customeraddressidreqd then dbms_output.put_line('Customer Address ID is a required field.');
        when e_custAddressNotFound then dbms_output.put_line('Invalid Customer Address ID.');
        when e_wrongInputs then dbms_output.put_line('At least one of the fields is required.');
        when e_invalidAddressType then dbms_output.put_line('Address Type must be BILLING/SHIPPING.');
        when e_invalidStateName then dbms_output.put_line('Invalid State Name.');
        when e_invalidZip then dbms_output.put_line('ZIP must be 5 digits.');
        when others then dbms_output.put_line('CONTACT ADMIN');
        rollback;
end;
/

/*steps for cust_address_update SP: exec cust_address_update(address_id, 'address_type'(billing/shipping), 'address_line1', 'address_line2', 'city', 
'state_name'(2 letter state code), 'zip')*/
