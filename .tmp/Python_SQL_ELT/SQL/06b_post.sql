BEGIN;

CREATE OR REPLACE PROCEDURE Staging.import_workflow_posting(
    IN p_session_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    new_session_id INT;
    table_related VARCHAR;
BEGIN
    
    SELECT session_id INTO new_session_id
    FROM Audit.import_sessions a
    WHERE a.session_id = p_session_id
    LIMIT 1;
    
    SELECT Staging.table_verification(new_session_id) INTO table_related;

    IF new_session_id IS NULL THEN
        RAISE EXCEPTION 'invalid Session ID : %', new_session_id;
    END IF;

    IF table_related IS NULL THEN   
        RAISE EXCEPTION 'Invalid table referecne : %',table_related;
    END IF;

    PERFORM 1 FROM Audit.import_sessions WHERE session_id = p_session_id;

    IF table_related = 'Staging.stg_sale_imports' THEN
        CALL Staging.post_sale_import(new_session_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging.import_workflow_posting failed : % ', SQLERRM;

END;
$$ SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-2 Data Posting Complete' AS STATUS;