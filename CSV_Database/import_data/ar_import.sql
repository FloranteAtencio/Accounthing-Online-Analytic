BEGIN;
COPY Bronze.stg_ar_imports (
    invoice_code,
    customer_code,
    client_code,
    amount,
    invoice_date,
    due_date,
    status
)
FROM './CSV_Database/data.csv'
WITH (FORMAT CSV, HEADER true);

COMMIT;

BEGIN;

INSERT INTO Support.import_workflows(staging_record_id,staging_table,new_state)

SELECT a.invoice_code, 'Bronze.stg_ar_imports', 'For Sanitation'

FROM Bronze.stg_ar_imports a

COMMIT;