BEGIN;

CREATE OR REPLACE PROCEDURE Staging.post_ar_import( IN p_session_id INT, p_import_type TEXT)
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
        FROM Bronze.stg_ar_imports a
        LEFT JOIN Audit.import_workflows b ON a.id = b.staging_record_id 
        WHERE a.session_id = p_session_id
          AND validation_status = 'VALID'
          AND b.new_state = 'VALID'
    LOOP
        INSERT INTO Silver.stg_ar_imports (
            session_id
            ,invoice_code
            ,client_code
            ,customer_code
            ,due_date
            ,invoice_date
            ,amount
            ,status)
        VALUES (
            TRIM(r.session_id::INT),
            TRIM(r.invoice_code::INT),
            TRIM(r.client_code::INT),
            TRIM(r.customer_code::INT),
            TRIM(r.due_date::DATE),
            TRIM(r.invoice_date::DATE),
            TRIM(r.amount::DECIMAL),
            UPPER(TRIM(r.status::VARCHAR))
        );        
        
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
            'stg_ar_import', 
            r.id, 
            r.client_code::INT, 
            p_import_type,
            current_setting('app.import_source_file', TRUE),
            p_session_id::INT,
            current_user,
            new_previous_hash,
            md5(
                COALESCE(new_previous_hash,'')
                || p_session_id
                || 'stg_ar_import'
                || p_import_type
                || r.id
                || current_user
            )
        );

    END LOOP;
        
    -- IF current_setting('app.import_session_id', TRUE) IS NOT NULL THEN


    UPDATE Audit.import_workflows
    SET new_state = 'POSTED',
        previous_state = 'APPROVE_L3'
    WHERE session_id = p_session_id AND new_state = 'APPROVE_L3';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging post_ar_import failed : % ', SQLERRM;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

COMMIT;

SELECT '14 Staging Schema import data posting complete' as Status;
