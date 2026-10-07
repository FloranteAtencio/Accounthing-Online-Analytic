-- ===================================================
-- This is where you can add and change the table returns for dynamic programming
-- just add if conditions inside the table verification
-- ===================================================
BEGIN;

DROP FUNCTION IF EXISTS Staging.table_verification(INT);
CREATE FUNCTION Staging.table_verification(p_session_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_table_name VARCHAR;
BEGIN
    
    IF EXISTS (
        SELECT 1 
        FROM Bronze.stg_ar_imports a 
        WHERE a.session_id = p_session_id
    ) THEN
        RETURN 'Bronze.stg_ar_imports'; -- Fixed typo in string and removed extra dot
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM Bronze.stg_ar_lines a 
        WHERE a.session_id = p_session_id
    ) THEN
        RETURN 'Bronze.stg_ar_lines'; -- Fixed typo in string and removed extra dot
    END IF;


    RETURN NULL; -- Explicit return if no match found
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Table verifications failed : %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;

-- =====================================
-- the main staging work flow santation
-- =====================================

CREATE OR REPLACE PROCEDURE Staging.import_workflow_sanitation(
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
        CALL Staging.ar_sanitation(new_session_id);

    ELSEIF table_related = 'Bronze.stg_ar_lines' THEN
        CALL Staging.ar_line_sanitation(new_session_id);

    ELSIF table_related = 'stg_other_table' THEN
        RAISE EXCEPTION 'Sanitation logic for stg_other_table is not yet implemented.';
    END IF;

 -- Ensure we only update records for this session
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging import sanitation failed for session %: %', p_session_id, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Bronze, Audit, Compliance, Staging, pg_catalog;


COMMIT;
SELECT '10 Staging Schema data sanitation complete' as Status;