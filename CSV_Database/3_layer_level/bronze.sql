BEGIN;

CREATE SCHEMA Bronze;

CREATE TABLE IF NOT EXISTS Bronze.stg_ar_imports(
    
    -- fact 
    -- lead column
    invoice_code TEXT,
    customer_code TEXT,
    client_code TEXT,

    -- measure
    amount TEXT,

    -- dim date
    invoice_date TEXT,
    due_date TEXT,

    -- metadata
    status TEXT

);

CREATE TABLE IF NOT EXISTS Bronze.stg_sale_imports(
    -- fact 
    -- lead column
    sale_order_code TEXT NOT NULL,
    
    -- Dimension
    -- date
    sale_date TEXT NOT NULL,
    sale_day TEXT NOT NULL,
    sale_month TEXT NOT NULL,
    sale_year TEXT NOT NULL,
    
    -- Dimension
    -- customer
    customer_age TEXT NOT NULL,
    age_group TEXT NOT NULL,
    customer_gender TEXT NOT NULL,
    
    -- Dimension
    -- locatoin
    country TEXT NOT NULL,
    state TEXT NOT NULL,
    
    -- Dimension
    -- product
    product_category TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    product TEXT NOT NULL,
    
    -- measure
    quantity TEXT NOT NULL,
    unit_cost TEXT NOT NULL,
    unit_price TEXT NOT NULL,
    profit TEXT NOT NULL,
    cost TEXT NOT NULL,
    revenue TEXT NOT NULL    
    -- meta data
);

COMMIT;

SELECT 'Bronse table schema complete!' as  Status;