
CREATE OR REPLACE PROCEDURE Staging.ar_import_workflow_validation(
    IN p_session_id INT
)
LANGUAGE plpgsql as $$
DECLARE
    new_session_id INT;
    r RECORD;
    z RECORD; -- This will hold the 4 error columns
BEGIN
    -- 1. Validate Session
    SELECT session_id INTO new_session_id
    FROM Audit.import_sessions a
    WHERE a.session_id = p_session_id
    LIMIT 1;

    IF new_session_id IS NULL THEN
        RAISE EXCEPTION 'Invalid Session ID: %', p_session_id; -- Fixed: use p_session_id, not new_session_id (which is NULL)
    END IF;

    -- 2. Loop through records
    FOR r IN
        SELECT 
            a.*,  
            c.table_name
        FROM Bronze.ar_line a
        LEFT JOIN Audit.import_workflows b ON a.id = b.staging_record_id 
        LEFT JOIN Audit.import_detail_logs c ON a.id = c.created_record_id
        WHERE a.session_id = p_session_id AND b.new_state = 'PENDING' -- Fixed: Handle case where workflow row might not exist yet
    
    LOOP

        -- Call the validation function
        SELECT *
        INTO z
        FROM Compliance.validate_ar_line_import(
            r.quantity::INT,
            r.discount::DECIMAL
           -- r.invoice_date::DATE,
           -- r.due_date::DATE,
           -- r.status::VARCHAR
        );

        -- ========================================================
        -- Amount Check 1
        -- ========================================================
        -- FIX: Use z.amount_error instead of z.v_errors_amount
        IF z.quantity_error IS NOT NULL THEN
            PERFORM Audit.import_validation(
                r.session_ r.table_name, 
                'INVALID: Quantity', r.amount, FALSE, 'ERROR'
            );
            PERFORM Compliance.log_compliance_check(
                r.client_code::INT
                , 5::INT
                , r.session_id::INT
                , r.id::INT
                , NULL
                , r.table_name
                , 'FAIL'
                , 'UNRESOLVED'
                , NULL
            );
        ELSE
            PERFORM Audit.import_validation(
                r.session_ r.table_name, 
                'Valid: Quantity  ', r.amount, TRUE, 'INFO'
            );
            PERFORM Compliance.log_compliance_check(
                r.client_code::INT
                , 5::INT
                , r.session_id::INT
                , r.id::INT
                , NULL
                , r.table_name
                , 'PASS'
                , 'RESOLVED'
                , NULL
            );
        END IF;

        -- ========================================================
        -- Invoice Date Check 2
        -- ========================================================
        -- FIX: Use z.Invoice_error instead of z.v_errors_invoice
        IF z.discount_error IS NOT NULL THEN
            PERFORM Audit.import_validation(
                r.session_ r.table_name, 
                'INVALID: Discount Rate!', r.invoice_date, FALSE, 'ERROR'
            );
            PERFORM Compliance.log_compliance_check(
                r.client_code::INT
                , 6::INT
                , r.session_id::INT
                , r.id::INT
                , NULL
                , r.table_name
                , 'FAIL'
                , 'UNRESOLVED'
                , NULL
            );
        ELSE
            PERFORM Audit.import_validation(
                r.session_ r.table_name, 
                'VALID: Discount rate!', r.invoice_date, TRUE, 'INFO'
            );
            PERFORM Compliance.log_compliance_check(
                r.client_code::INT
                , 6::INT
                , r.session_id::INT
                , r.id::INT
                , NULL
                , r.table_name
                , 'PASS'
                , 'RESOLVED'
                , NULL
            );
        END IF;

        -- ========================================================
        -- Customer Check 3
        -- ========================================================
        -- FIX: Use z.customer_error instead of z.v_errors_customer
        -- IF z.customer_error IS NOT NULL THEN
        --     PERFORM Audit.import_validation(
        --         r.session_ r.table_name, 
        --         'INVALID: Customer not exists!', r.customer_code, FALSE, 'ERROR'
        --     );
        --     PERFORM Compliance.log_compliance_check(
        --         r.client_code::INT
        --         , 3::INT
        --         , r.session_id::INT
        --         , r.id::INT
        --         , NULL
        --         , r.table_name
        --         , 'FAIL'
        --         , 'UNRESOLVED'
        --         , NULL
        --     );
        -- ELSE
        --     PERFORM Audit.import_validation(
        --         r.session_ r.table_name, 
        --         'VALID: Customer!', r.customer_code, TRUE, 'INFO'
        --     );
        --     PERFORM Compliance.log_compliance_check(
        --         r.client_code::INT
        --         , 3::INT
        --         , r.session_id::INT
        --         , r.id::INT
        --         , NULL
        --         , r.table_name
        --         , 'PASS'
        --         , 'RESOLVED'
        --         , NULL
        --     );
        -- END IF;

        -- ========================================================
        -- Status Check 4
        -- ========================================================
        -- -- FIX: Use z.status_error instead of z.v_errors_status
        -- IF z.status_error IS NOT NULL THEN
        --     PERFORM Audit.import_validation(
        --         r.session_ r.table_name, 
        --         'INVALID: Status Check!', r.status, FALSE, 'ERROR'
        --     );
        --     -- Log status fail if needed
        --     PERFORM Compliance.log_compliance_check(
        --        r.client_code::INT
        --         , 4::INT
        --         , r.session_id::INT
        --         , r.id::INT
        --         , NULL
        --         , r.table_name
        --         , 'FAIL'
        --         , 'UNRESOLVED'
        --         , NULL
        --     );
        -- ELSE
        --     PERFORM Audit.import_validation(
        --         r.session_ r.table_name, 
        --         'Valid: Status!', r.status, TRUE, 'INFO'
        --     );
        --     -- Log status pass if needed
        --     PERFORM Compliance.log_compliance_check(
        --        r.client_code::INT
        --         , 4::INT
        --         , r.session_id::INT
        --         , r.id::INT
        --         , NULL
        --         , r.table_name
        --         , 'PASS'
        --         , 'RESOLVED'
        --         , NULL
        --     );
        -- END IF;

        -- ========================================================
        -- Update Workflow Status (Only if ALL checks passed)
        -- ========================================================
        -- Logic: If ANY error was found, we should NOT update to 'VALID'.
        -- We only update if ALL four are NULL.
        IF z.quantity_error_error IS NULL 
           AND z.discount_error IS NULL 
           -- AND z.customer_error IS NULL 
           -- AND z.status_error IS NULL 
           THEN
            
            UPDATE Audit.import_workflows 
            SET 
                new_state = 'VALID',
                previous_state = 'PENDING',
                notes = 'PENDING FOR APPROVAL'
            WHERE Audit.import_workflows.session_id = r.session_id
              AND Audit.import_workflows.staging_record_id = r.id;
        END IF;
    
    END LOOP;    

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Procedure ar_import_workflow_validation failed: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

