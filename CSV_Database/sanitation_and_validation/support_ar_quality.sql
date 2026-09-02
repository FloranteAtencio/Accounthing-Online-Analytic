BEGIN;

CREATE OR REPLACE PROCEDURE Support.ar_sanitation()
LANGUAGE plpgsql as $$
DECLARE
    collect_errors TEXT[] := ARRAY[]::TEXT[];
    r RECORD;
BEGIN


    FOR r IN    
        SELECT *
        FROM Bronze.stg_ar_imports a
    LOOP

        IF r.amount !~ '^\.?\d+(\.\d+)?$' THEN 
            collect_errors := array_append(collect_errors,'Invalid amount format');
        END IF;
        
        IF r.invoice_date !~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$' THEN 
            collect_errors := array_append(collect_errors,'Invalid Date');  
        END IF;
        
        IF r.due_date !~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$' THEN 
            collect_errors := array_append(collect_errors,'Invalid Date');
        END IF;

        IF r.status NOT IN ('Pending', 'Paid', 'Overdue','Returned','Partially Returned','Partially Paid') THEN 
            collect_errors := array_append(collect_errors,'INVALID Status');
        END IF;

    UPDATE Bronze.stg_ar_imports s
    SET 
        validation_status = CASE WHEN array_length(collect_errors, 1) = 0 THEN 'SANITATION VALID' ELSE 'SANITATION INVALID' END,
        validation_errors = CASE WHEN array_length(collect_errors, 1) = 0 THEN NULL ELSE array_to_string(collect_errors, '; ') END,
    WHERE s.invoice_code = r.invoice_code AND validation_status = 'DRAFT';

    collect_errors := ARRAY[]::TEXT[];

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Support.ar_sanitation Failed: %', SQLERRM;

END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

CREATE OR REPLACE PROCEDURE Support.ar_import_workflow_validation()
LANGUAGE plpgsql as $$
DECLARE
    r RECORD;
    z RECORD; -- This will hold the 4 error columns
BEGIN

    FOR r IN
        SELECT 
            a.*
        FROM Bronze.stg_ar_imports a 
        WHERE validation_status = 'SANITATION VALID'   
    LOOP

        -- Call the validation function
        FROM Support.validate_ar_import(
            r.invoice_code TEXT,
            r.amount DECIMAL,
            r.invoice_date DATE,
            r.due_date DATE,
            r.status VARCHAR
        );
    
    END LOOP;    

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Support.ar_import_workflow_validation Failed: %', SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

CREATE OR REPLACE PROCEDURE Support.validate_ar_import(
    p_invoice_code TEXT,
    p_amount DECIMAL,
    p_invoice_date DATE,
    p_due_date DATE,
    p_status VARCHAR
)
LANGUAGE plpgsql as $$
DECLARE
    collect_errors TEXT[] := ARRAY[]::TEXT[];
BEGIN
    IF p_amount <= 0 THEN
        collect_errors := array_append(collect_errors,'AR amount must be positive');        
    END IF;
    
    -- Validate dates
    IF p_invoice_date > p_due_date THEN
        collect_errors := array_append(collect_errors,'Invoice date cannot be after due date');        
    END IF;
        
    -- Validate status
    IF p_status NOT IN ('Pending', 'Paid', 'Overdue','Returned','Partially Returned','Partially Paid') THEN
        collect_errors := array_append(collect_errors,'Invalid AR status');        
    END IF;

    UPDATE Bronze.stg_ar_imports s
    SET 
        validation_status = CASE WHEN array_length(collect_errors, 1) = 0 THEN 'VALIDATION VALID' ELSE 'VALIDATION INVALID' END,
        validation_errors = CASE WHEN array_length(collect_errors, 1) = 0 THEN NULL ELSE array_to_string(collect_errors, '; ') END,
    WHERE s.invoice_code = p_invoice_code AND validation_status = 'SANITATION VALID';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Support.validate_ar_import Failed: %', SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

COMMIT;
SELECT 'Part-2 Data sanitation complete' as Status;