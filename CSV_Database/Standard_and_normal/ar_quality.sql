SELECT *
FROM (
    SELECT
        TRIM(invoice_code)   AS invoice_code,
        TRIM(customer_code)  AS customer_code,
        TRIM(client_code)    AS client_code,
        TRIM(amount)         AS amount,
        TRIM(invoice_date)   AS invoice_date,
        TRIM(due_date)       AS due_date,
        TRIM(status)         AS status,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(invoice_code)
            ORDER BY TRIM(invoice_code)
        ) AS Uniq
    FROM Bronze.stg_ar_imports
) sub;   