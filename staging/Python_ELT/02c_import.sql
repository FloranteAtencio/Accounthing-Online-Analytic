BEGIN;
-- Function to log an import record
-- This is the function where you need to call after the after the process in the main schema table related.
DROP FUNCTION IF EXISTS Audit.log_import_record(INT, INT, VARCHAR, JSONB, VARCHAR, TEXT, INT) CASCADE;
CREATE FUNCTION Audit.log_import_record(
    p_session_id INT,
    p_row_number INT,
    p_table_name VARCHAR,
    p_record_data JSONB,
    p_status VARCHAR,
    p_error_message TEXT DEFAULT NULL,
    p_created_record_id INT DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_detail_id BIGINT;
BEGIN
    INSERT INTO Audit.import_detail_logs (
        session_id, row_number, table_name, record_data, 
        status, error_message, created_record_id
    )
    VALUES (p_session_id, p_row_number, p_table_name, p_record_data, 
            p_status, p_error_message, p_created_record_id)
    RETURNING detail_id INTO v_detail_id;
    
    -- Update import session counts
    UPDATE Audit.import_sessions
    SET total_records = total_records + 1,
        successful_records = CASE WHEN p_status = 'SUCCESS' THEN successful_records + 1 ELSE successful_records END,
        failed_records = CASE WHEN p_status = 'FAILED' THEN failed_records + 1 ELSE failed_records END
    WHERE session_id = p_session_id;
    
    RETURN v_detail_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;
COMMIT;

SELECT 'Part-3 Data Import Complete
' AS STATUS;