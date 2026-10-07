-- =====================================
-- add more procedure for sanitation for each staging table
-- =====================================

BEGIN;

CREATE OR REPLACE PROCEDURE Staging.sale_sanitation(
    IN p_session_id INT
)
LANGUAGE plpgsql as $$
DECLARE
    collect_errors TEXT[] := ARRAY[]::TEXT[];
    r RECORD;
BEGIN

    FOR r IN    
        SELECT *
        FROM Staging.stg_sale_imports a
    --    WHERE a.session_id = p_session_id
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

        -- validation status updating logs every errors collected
        UPDATE Staging.stg_sale_imports s
        SET 
            validation_status = 
                CASE 
                WHEN
                    array_length(collect_errors,1) IS NULL THEN 
                        'VALID' 
                ELSE 
                        'INVALID' 
                END ,
            validation_errors = 
                CASE 
                WHEN
                    array_length(collect_errors,1) IS NULL THEN 
                        NULL  
                    ELSE 
                        array_to_string(collect_errors, '; ')
                END
        WHERE s.session_id = p_session_id
        AND s.validation_status = 'DRAFT'
        AND s.id = r.id;
        
        collect_errors := ARRAY[]::TEXT[];

    END LOOP;

    UPDATE Staging.import_workflows a
    SET
        new_state = 'PENDING',
        previous_state = 'DRAFT',
        notes = 'PENDING FOR VALIDATION'
    FROM Staging.stg_sale_imports b
    WHERE a.staging_record_id = b.id 
    AND a.session_id = b.session_id
    AND b.validation_status = 'VALID'
    AND a.session_id = p_session_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Account Receivables Sanitations Failed: %', SQLERRM;

END;
$$ SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;


COMMIT;
SELECT 'Part-3 Data sanitation complete' as Status;