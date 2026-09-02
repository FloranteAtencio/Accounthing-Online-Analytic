BEGIN;

CREATE SCHEMA Support;

CREATE OR REPLACE PROCEDURE Support.import_workflow_sanitation(
    IN p_table_related INT
)
LANGUAGE plpgsql AS $$
DECLARE
BEGIN
 
    IF p_table_related IS NULL THEN
        RAISE EXCEPTION 'Invalid table name: %. Not Allowed:', p_table_related;
    END IF;
        
    IF p_table_related = 'Bronze.stg_sale_imports' THEN
        CALL Support.sale_sanitation();
        CALL Support.sale_import_workflow_validation()
    END IF;

    IF p_table_related = 'Bronze.stg_ar_imports' THEN
        CALL Support.ar_sanitation();
        CALL Support.ar_import_workflow_validation()
    END IF;
    
    IF  p_table_related IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid table out range: %. Not Allowed:', p_table_related;        
    END  IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION ' Support.import_workflow_sanitation failed for session %',SQLERRM;
END;
$$ SECURITY DEFINER SET search_path = Bronze,Silver,Gold,Support, pg_catalog;

COMMIT;

SELECT 'Support Main procedure/functions' AS STATUS;