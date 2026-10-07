BEGIN;
-- Function to complete an import session
DROP FUNCTION IF EXISTS Audit.complete_import_session(INT, VARCHAR, TEXT) CASCADE;
CREATE FUNCTION Audit.complete_import_session(
    p_session_id INT,
    p_final_status VARCHAR,
    p_error_summary TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE Audit.import_sessions
    SET status = p_final_status,
        completed_at = CURRENT_TIMESTAMP,
        error_summary = p_error_summary
    WHERE session_id = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-4 Data Import Complete' as STATUS;
