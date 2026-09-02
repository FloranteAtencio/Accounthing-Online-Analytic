
BEGIN;

CREATE OR REPLACE PROCEDURE Support.sale_sanitation()
LANGUAGE plpgsql as $$
DECLARE
    collect_errors TEXT[] := ARRAY[]::TEXT[];
    r RECORD;
BEGIN

    FOR r IN 
        SELECT * 
        FROM Bronze.stg_sale_imports 
        WHERE validation_status = 'DRAFT'
    LOOP

        IF r.unit_cost::text !~ '^\.?\d+(\.\d+)?$' THEN 
             collect_errors := array_append(collect_errors,'Invalid unit cost');
         END IF;

        IF r.unit_price::text !~ '^\.?\d+(\.\d+)?$' THEN
             collect_errors := array_append(collect_errors,'Invalid unit price');
         END IF;

        IF r.profit::text !~ '^\.?\d+(\.\d+)?$' THEN 
             collect_errors := array_append(collect_errors,'Invalid profit');
         END IF;

        IF r.cost::text !~ '^\.?\d+(\.\d+)?$' THEN 
             collect_errors := array_append(collect_errors,'Invalid cost');
         END IF;

        IF r.revenue::text !~ '^\.?\d+(\.\d+)?$' THEN 
             collect_errors := array_append(collect_errors,'Invalid revenue');
         END IF;

        IF r.customer_age::text !~ '^\d+$' THEN
            collect_errors := array_append(collect_errors,'Invalid AGE format');
        END IF;
        
        IF r.quantity::text !~ '^\d+$' THEN
            collect_errors := array_append(collect_errors,'Invalid AGE format');
        END IF;
        
        IF r.age_group::text NOT IN ('Young Adults (25-34)','Adults (35-64)','Youth (<25)') THEN 
            collect_errors := array_append(collect_errors,'INVALID AGE GROUP');
        END IF;        

        IF r.customer_gender::text NOT IN ('F','M','f','m','u','U') THEN
            collect_errors := array_append(collect_errors,'INVALID CUSTOMER GENDER');
        END IF;
        
        IF r.country::text !~ '^[A-Za-z]+$' THEN
            collect_errors := array_append(collect_errors, 'Invalid COUNTRY');
        END IF;   

        IF r.state::text !~ '^[A-Za-z]+$' THEN
            collect_errors := array_append(collect_errors, 'Invalid STATE');
        END IF;   

        IF r.sub_category::text NOT IN ('Mountain Bikes','Road Bikes') THEN
            collect_errors := array_append(collect_errors, 'Invalid Sub Category');
        END IF;

        IF r.product::text !~ '^(Road|Mountain)-\d+(-W)? (Red|Black|Yellow|Silver), \d{2}$' THEN
            collect_errors := array_append(collect_errors, 'Invalid Product');
        END IF;

        IF r.sale_date::text !~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$' THEN 
            collect_errors := array_append(collect_errors,'Invalid Date');
        END IF;

        IF r.sale_month::text NOT IN ('January', 'Febuary', 'March', 'April', 'May','June','July', 'August','September','October','November','December') THEN 
            collect_errors := array_append(collect_errors,'INVALID Mont');
        END IF;

        IF r.sale_day::text NOT BETWEEN 1 AND 31 THEN
            collect_errors := array_append(collect_errors, 'INVALID day');
        END IF;   

        IF r.sale_year::text NOT BETWEEN 2001 AND 2031 THEN
            collect_errors := array_append(collect_errors, 'INVALID year');
        END IF;   

    UPDATE Support.import_workflows s
    SET 
        previous_state = 'For Sanitation',
        new_state = 'For Validation' ,
        validation_status = CASE WHEN array_length(collect_errors, 1) = 0 THEN 'SANITATION VALID' ELSE 'SANITATION INVALID' END,
        validation_errors = CASE WHEN array_length(collect_errors, 1) = 0 THEN NULL ELSE array_to_string(collect_errors, '; ') END,
    WHERE s.staging_record_id = r.sale_order_code AND s.staging_table = 'Bronze.stg_sale_imports' AND validation_status = 'DRAFT';

    collect_errors := ARRAY[]::TEXT[];

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'SALE Sanitations Failed: %', SQLERRM;

END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;


CREATE OR REPLACE PROCEDURE Support.sale_import_workflow_validation()
LANGUAGE plpgsql as $$
DECLARE
    r RECORD;
    z RECORD; -- This will hold the 4 error columns
BEGIN

    FOR r IN
        SELECT 
            a.*
        FROM Bronze.stg_sale_imports a 
        WHERE validation_status = 'SANITATION VALID'   
    LOOP

        -- Call the validation function
        FROM Support.validate_sale_import(
            r.sale_order_code::TEXT,
            r.customer_age::INT,
            r.unit_price::DECIMAL,
            r.order_quantity INT,
            r.revenue DECIMAL,
            r.unit_cost DECIMAL,
            r.cost DECIMAL,
            r.profit DECIMAL

        );
    
    END LOOP;    

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Support.sale_import_workflow_validation Failed: %', SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

CREATE OR REPLACE PROCEDURE Support.validate_sale_import(
    p_sale_order_code TEXT,
    p_customer_age INT,
    p_unit_price DECIMAL,
    p_order_quantity INT,
    p_revenue DECIMAL,
    p_unit_cost DECIMAL,
    p_cost DECIMAL,
    p_profit DECIMAL

)
LANGUAGE plpgsql as $$
DECLARE
    collect_errors TEXT[] := ARRAY[]::TEXT[];
BEGIN

    -- Validate age and age group
    IF p_customer_age < 0 OR p_customer_age > 64 THEN
        collect_errors := array_append(collect_errors,'Kindly Check Age');        
    END IF;   

    -- finance
    IF p_unit_price * p_order_quantity != p_revenue THEN
        collect_errors := array_append(collect_errors,'Revenue not match');        
    END IF;

    IF p_unit_cost * p_order_quantity != p_cost THEN
        collect_errors := array_append(collect_errors,'Cost not match');        
    END IF;

    IF p_revenue - p_cost != p_profit THEN
        collect_errors := array_append(collect_errors,'Profit not match');        
    END IF;

    UPDATE Support.import_workflows s
    SET 
        previous_state = 'For Validation',
        new_state = 'For Posting' ,
        validation_status = CASE WHEN array_length(collect_errors, 1) = 0 THEN 'VALIDATION VALID' ELSE 'VALIDATION INVALID' END,
        validation_errors = CASE WHEN array_length(collect_errors, 1) = 0 THEN NULL ELSE array_to_string(collect_errors, '; ') END,
    WHERE s.staging_record_id = p_sale_order_code AND s.staging_table = 'Bronze.stg_sale_imports' AND validation_status = 'SANITATION VALID';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Support.validate_sale_import Failed: %', SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

COMMIT;
SELECT 'Part-2 Data sanitation complete' as Status;