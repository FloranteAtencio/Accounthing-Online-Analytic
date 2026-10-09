BEGIN;

DROP FUNCTION IF EXISTS Staging.ar_import_data(INT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT) CASCADE;
CREATE FUNCTION Staging.ar_import_data(
    p_session_id        INT,
    p_invoice_id        TEXT,
    p_client_id         TEXT,
    p_customer_id       TEXT,
    p_invoice_date      TEXT,
    p_due_date          TEXT,
    p_amount            TEXT,
    p_status            TEXT,
    p_import_status     TEXT,
    p_idempotency_key   TEXT
)
RETURNS INT AS $$
DECLARE
    new_previous_hash TEXT;
    new_ar_staging_id INT;
BEGIN

    SELECT row_hash
    INTO new_previous_hash
    FROM Audit.record_lineage
    ORDER BY lineage_id DESC
    LIMIT 1
    FOR UPDATE;

    -- Attempt insert
    INSERT INTO Bronze.stg_ar_imports( 
        session_id, invoice_code, client_code, customer_code,
        invoice_date, due_date, amount, status,
        validation_status, validation_errors, imported_at, idempotency_key
    ) VALUES ( 
        p_session_id, p_invoice_id, p_client_id, p_customer_id,
        p_invoice_date, p_due_date, p_amount, p_status,
        'DRAFT', NULL, NOW(), p_idempotency_key
    )
    ON CONFLICT (idempotency_key) DO NOTHING
    RETURNING id INTO new_ar_staging_id;

    -- Handle duplicate case
    IF new_ar_staging_id IS NULL THEN
        SELECT id INTO new_ar_staging_id 
        FROM Bronze.stg_ar_imports 
        WHERE idempotency_key = p_idempotency_key;
        
        RAISE NOTICE 'Duplicate skipped for key %. Reusing existing id %.', 
            p_idempotency_key, new_ar_staging_id;
    END IF;

    INSERT INTO Audit.import_workflows
    (session_id, staging_record_id, staging_table,previous_state, new_state, changed_by)
    VALUES(p_session_id, new_ar_staging_id, 'ar_import_data',NULL, 'DRAFT',current_user);

    -- IF current_setting('app.import_session_id', TRUE) IS NOT NULL THEN
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
            new_ar_staging_id, 
            p_client_id::INT, 
            p_import_status,
            current_setting('app.import_source_file', TRUE),
            p_session_id::INT,
            current_user,
            new_previous_hash,
            md5(
                COALESCE(new_previous_hash,'')
                || p_session_id
                || 'stg_ar_import'
                || p_import_status
                || new_ar_staging_id
                || current_user
            )
    );
    -- END IF;

    RETURN new_ar_staging_id;
END; 
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;


DROP FUNCTION IF EXISTS Staging.ar_line_import_data(INT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT,TEXT) CASCADE;
CREATE FUNCTION Staging.ar_import_data(
    p_session_id        INT,
    p_client_id         TEXT,
    p_invoice_id        TEXT,
    p_product_code      TEXT,
    p_quantity          TEXT,
    p_discount          TEXT,
    p_import_status     TEXT,
    p_idempotency_key   TEXT
)
RETURNS INT AS $$
DECLARE
    new_previous_hash TEXT;
    new_ar_staging_id INT;
BEGIN

    SELECT row_hash
    INTO new_previous_hash
    FROM Audit.record_lineage
    ORDER BY lineage_id DESC
    LIMIT 1
    FOR UPDATE;

    -- Attempt insert
    INSERT INTO Bronze.ar_line( 
        session_id,  client_code, invoice_code, product_code, quantity,
        discount, validation_status, validation_errors,
        imported_at, idempotency_key
    ) VALUES ( 
        p_session_id, p_client_id, p_invoice_id, p_product_code, p_quantity,
        p_discount,'DRAFT', NULL, 
        NOW(), p_idempotency_key
    )
    ON CONFLICT (idempotency_key) DO NOTHING
    RETURNING id INTO new_ar_staging_id;

    -- Handle duplicate case
    IF new_ar_staging_id IS NULL THEN
        SELECT id INTO new_ar_staging_id 
        FROM Bronze.stg_ar_imports 
        WHERE idempotency_key = p_idempotency_key;
        
        RAISE NOTICE 'Duplicate skipped for key %. Reusing existing id %.', 
            p_idempotency_key, new_ar_staging_id;
    END IF;

    INSERT INTO Audit.import_workflows
    (session_id, staging_record_id, staging_table,previous_state, new_state, changed_by)
    VALUES(p_session_id, new_ar_staging_id, 'ar_import_data',NULL, 'DRAFT',current_user);

    -- IF current_setting('app.import_session_id', TRUE) IS NOT NULL THEN
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
            'ar_line', 
            new_ar_staging_id, 
            p_client_id::INT, 
            p_import_status,
            current_setting('app.import_source_file', TRUE),
            p_session_id::INT,
            current_user,
            new_previous_hash,
            md5(
                COALESCE(new_previous_hash,'')
                || p_session_id
                || 'ar_line'
                || p_import_status
                || new_ar_staging_id
                || current_user
            )
    );
    -- END IF;

    RETURN new_ar_staging_id;
END; 
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

COMMIT;

