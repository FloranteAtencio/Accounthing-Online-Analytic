CREATE OR REPLACE PROCEDURE Staging.import_workflow_approval_L1(
    IN p_session_id INT,
    IN p_approve_by VARCHAR(20) -- MANAGER, BOOKKEEPER, ACCOUNTANT
)
LANGUAGE plpgsql as $$
DECLARE
    new_session_id INT;
    new_previous_state VARCHAR(50);
BEGIN

    SELECT session_id INTO new_session_id
    FROM Audit.import_sessions a
    WHERE a.session_id = p_session_id
    LIMIT 1;
    
    IF new_session_id IS NULL THEN
        RAISE EXCEPTION 'Please Check Session_id provided!';
    END IF;

    PERFORM 1 FROM Audit.import_sessions a where a.session_id = p_session_id;

    INSERT INTO Staging.import_approvals (session_id, staging_record_id,approval_status,approval_level,approved_by)
    SELECT  a.session_id,
            a.staging_record_id,
            'APPROVE',
            1,
            p_approve_by
    FROM Staging.import_workflows a 
    WHERE a.new_state = 'VALID' AND a.session_id = new_session_id;

    UPDATE Staging.import_workflows
    SET new_state = 'APPROVE',
        previous_state = 'VALID'
    WHERE session_id = new_session_id AND new_state = 'VALID';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Staging import approval failed: %', SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;
