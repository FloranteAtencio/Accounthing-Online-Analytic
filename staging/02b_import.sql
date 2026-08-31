BEGIN;

-- Function to start an import session
-- This is the very first function needed to call
DROP FUNCTION IF EXISTS Audit.start_import_session(INT, VARCHAR, VARCHAR, VARCHAR) CASCADE;
CREATE FUNCTION Audit.start_import_session(
    p_client_id INT,
    p_import_type VARCHAR,
    p_imported_by VARCHAR,
    p_source_file VARCHAR DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_session_id INT;
BEGIN
    INSERT INTO Audit.import_sessions (client_id, import_type, imported_by, source_file, status)
    VALUES (p_client_id, p_import_type, p_imported_by, p_source_file, 'IN_PROGRESS')
    RETURNING session_id INTO v_session_id;
    
    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-2 Data Import Complete' AS STATUS;