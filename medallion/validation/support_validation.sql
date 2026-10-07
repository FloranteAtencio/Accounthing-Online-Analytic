BEGIN;

CREATE OR REPLACE FUNCTION Audit.import_validation(
    p_session_id INT,
    p_row_number INT,
    p_field_name VARCHAR,
    p_validation_rule VARCHAR,
    p_actual_value TEXT,
    p_is_valid BOOLEAN,
    p_severity VARCHAR
)
RETURNS BIGINT AS $$
DECLARE

    new_id BIGINT;

BEGIN

    INSERT INTO Audit.import_validation_log(
        session_id
        ,row_number
        ,field_name
        ,validation_rule 
        ,actual_value 
        ,is_valid 
        ,severity -- 'ERROR', 'WARNING', 'INFO'
        
    )
    VALUES(
        p_session_id
        , p_row_number
        , p_field_name
        , p_validation_rule
        , p_actual_value
        , p_is_valid
        , p_severity
        
    )
    RETURNING validation_id INTO new_id;

    RETURN new_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

-- =============================================================
-- Staging validations END
-- Account Receivables Procedure
-- =============================================================


-- =====================================
-- the main staging work flow santation
-- =====================================

CREATE OR REPLACE PROCEDURE Staging.main_import_workflow_validation(
    IN p_session_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    table_related VARCHAR;
    new_session_id INT;
BEGIN

    -- 1. Validate Session ID
    SELECT session_id INTO new_session_id
    FROM Audit.import_sessions
    WHERE session_id = p_session_id
    LIMIT 1;

    IF new_session_id IS NULL THEN
        RAISE EXCEPTION 'Invalid Session ID: %', p_session_id;
    END IF;

    SELECT Staging.table_verification(new_session_id) INTO table_related;
 
    -- 2. Validate Table Name (Whitelist approach)
    IF table_related IS NULL THEN
        RAISE EXCEPTION 'Invalid table name: %. Not Allowed:', table_related;
    END IF;
    
    PERFORM 1 FROM Audit.import_sessions WHERE session_id = p_session_id;
    
    -- 3. Execute Table-Specific Sanitation
    IF table_related = 'Bronze.stg_ar_imports' THEN
        CALL Staging.ar_import_workflow_validation(new_session_id);
        
    ELSIF table_related = 'stg_other_table' THEN
        RAISE EXCEPTION 'Sanitation logic for stg_other_table is not yet implemented.';
            
    END IF;

 -- Ensure we only update records for this session
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging import Main Validations failed for session %: %', p_session_id, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

COMMIT;

SELECT '11 Staging Schema import data validations complete' as Status;