BEGIN;

CREATE OR REPLACE PROCEDURE Staging.post_sale_import( IN p_session_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    new_previous_state VARCHAR(50);
    new_previous_hash VARCHAR(50);
BEGIN    

    SET LOCAL app.allow_direct_insert = 'true';
    
    FOR r IN
        SELECT a.*
        FROM Staging.stg_sale_imports a
        LEFT JOIN Staging.import_workflows b ON a.id = b.staging_record_id 
        WHERE a.session_id = p_session_id
          AND validation_status = 'VALID'
          AND b.new_state = 'APPROVE'
    LOOP
        
        -- CALL Finance.ar_transaction(
        --     r.client_code::INT,
        --     r.customer_code::INT,
        --     r.due_date::DATE,
        --     r.invoice_date::DATE,
        --     r.amount::DECIMAL,
        --     r.status::VARCHAR,
        --     gen_random_uuid()::TEXT
        -- );
    
        SELECT row_hash
        INTO new_previous_hash
        FROM Audit.record_lineage
        ORDER BY lineage_id DESC
        LIMIT 1
        FOR UPDATE;
        
        INSERT INTO Audit.record_lineage (
            table_name, 
            record_id, 
            client_id, 
            source_type, 
            source_file, 
            import_session_id, 
            created_by,
            prev_hash, 
            row_hash
        ) VALUES (
            'stg_sale_imports', 
            r.id, 
            r.client_code::INT, 
            'SPREADSHEET_IMPORT',
            current_setting('app.import_source_file', TRUE),
            p_session_id::INT,
            current_user,
            new_previous_hash,
            md5(
                COALESCE(new_previous_hash,'')
                || p_session_id
                || 'stg_sale_imports'
                || 'SPREADSHEET_IMPORT'
                || r.id
                || current_user
            )
        );

    END LOOP;
        
    -- IF current_setting('app.import_session_id', TRUE) IS NOT NULL THEN


    UPDATE Staging.import_workflows
    SET new_state = 'POSTED',
        previous_state = 'APPROVE'
    WHERE session_id = p_session_id AND new_state = 'APPROVE';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging post_sale_import failed : % ', SQLERRM;

END;
$$ SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;


COMMIT;

SELECT 'Part-1 Data Posti complete' as Status;
