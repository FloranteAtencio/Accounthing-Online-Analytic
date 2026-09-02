BEGIN;
COPY Bronze.stg_ar_imports (
    sale_order_code,-- TEXT NOT NULL,    
    -- Dimension
    -- date
    sale_date,-- TEXT NOT NULL,
    sale_day,-- TEXT NOT NULL,
    sale_month,-- TEXT NOT NULL,
    sale_year,-- TEXT NOT NULL,
    -- Dimension
    -- customer
    customer_age,-- TEXT NOT NULL,
    age_group,-- TEXT NOT NULL,
    customer_gender,-- TEXT NOT NULL,
    -- Dimension
    -- locatoin
    country,-- TEXT NOT NULL,
    state,-- TEXT NOT NULL,
    -- Dimension
    -- product
    product_category,-- TEXT NOT NULL,
    sub_category,-- TEXT NOT NULL,
    product,--TEXT NOT NULL,
    -- measure
    quantity,-- TEXT NOT NULL,
    unit_cost,-- TEXT NOT NULL,
    unit_price,-- TEXT NOT NULL,
    profit,-- TEXT NOT NULL,
    cost,-- TEXT NOT NULL,
    revenue-- TEXT NOT NULL
)
FROM './CSV_Database/Bike_Sales_VLOOKUP.csv'
WITH (FORMAT CSV, HEADER true);

COMMIT;


BEGIN;

INSERT INTO Support.import_workflows(staging_record_id,staging_table,new_state)

SELECT a.invoice_code, 'Bronze.stg_sale_imports', 'For Sanitation'

FROM Bronze.stg_sale_imports a

COMMIT;