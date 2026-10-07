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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-3 Data Validation Complete!' AS STATUS;