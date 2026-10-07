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
        FROM Staging.stg_sale_imports a 
        WHERE a.session_id = p_session_id
    ) THEN
        RETURN 'Staging.stg_sale_imports'; -- Fixed typo in string and removed extra dot
    END IF;

    RETURN NULL; -- Explicit return if no match found
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Table verifications failed : %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;


COMMIT;
SELECT 'Part-1 Data sanitation complete' as Status;