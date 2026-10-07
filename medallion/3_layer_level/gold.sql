BEGIN;

CREATE SCHEMA Gold;

DROP TABLE IF EXISTS Gold.dim_account;
CREATE TABLE IF NOT EXISTS Gold.dim_account(

    account_key BIGINT,
    account_id INT,
    account_name VARCHAR(50),
    account_type VARCHAR(50),
    account_role VARCHAR(50),
    account_category VARCHAR(50),
    UNIQUE(account_key, account_id)

);

DROP TABLE IF EXISTS Gold.dim_date;
CREATE TABLE IF NOT EXISTS Gold.dim_date(

    date_key BIGINT,
    date DATE,
    day VARCHAR(50),
    month VARCHAR(50),
    month_name VARCHAR(50),
    quarter VARCHAR(50),
    year VARCHAR(50),
    week VARCHAR(50),
    day_of_week VARCHAR(50),
    UNIQUE(date_key,date)

);


-- Client information
DROP TABLE IF EXISTS Gold.dim_client;
CREATE TABLE IF NOT EXISTS Gold.dim_client(

    client_key BIGINT,
    client_id INT,
    client_name TEXT,
    client_type VARCHAR(50),
    industry TEXT,
    country VARCHAR(50),
    region TEXT,
    UNIQUE(client_key,client_id)

);

-- Client information
DROP TABLE IF EXISTS Gold.dim_customer;
CREATE TABLE IF NOT EXISTS Gold.dim_customer(

    customer_key BIGINT,
    customer_id INT,
    customer_name VARCHAR(50),
    customer_type VARCHAR(50),
    industry TEXT,
    country VARCHAR(50),
    region TEXT,
    UNIQUE(customer_key,customer_id)

);

-- Location information
DROP TABLE IF EXISTS Gold.dim_location;
CREATE TABLE IF NOT EXISTS Gold.dim_location(

    location_key BIGINT,
    location_id INT,
    country TEXT,
    region TEXT,
    province TEXT,
    city TEXT,
    municipality TEXT,
    barangay TEXT,
    UNIQUE(location_key,location_id)

);

DROP TABLE IF EXISTS Gold.dim_currency;
CREATE TABLE IF NOT EXISTS Gold.dim_currency(

    currency_key BIGINT,
    currency_id INT,
    currency_code TEXT,
    currency_name TEXT,
    symbol TEXT,
    UNIQUE(currency_key,currency_id)

);


-- DROP TABLE IF EXISTS Gold.invoice_date;
-- CREATE TABLE IF NOT EXISTS Gold.invoice_date(

-- invoice_date_key VARCHAR(50),
-- invoice_date_id INT,
-- invoice_date DATE,
-- UNIQUE(invoice_date_key,invoice_date_id)

-- );


-- DROP TABLE IF EXISTS Gold.due_date;
-- CREATE TABLE IF NOT EXISTS Gold.due_date(
--     due_date_key VARCHAR(50),
--     due_date_id INT,  -- Note: second field should probably be due_date_id
--     due_date DATE,
--     UNIQUE(due_date_key,due_date_id)
-- );

DROP TABLE IF EXISTS Gold.product;
CREATE TABLE IF NOT EXISTS Gold.product(
    product_key BIGINT,
    product_id INT,
    product_name VARCHAR(50),
    product_line_name VARCHAR(50),
    product_effective Date,
    product_expired date,
    UNIQUE(product_key,product_id)
);

COMMIT;
BEGIN;

CREATE TABLE Gold.fact_gl (

    general_ledger_id INT,
--    journal_id INT,

    transaction TEXT,
    account_key VARCHAR(50),
    client_key VARCHAR(50),
    journal_date_key VARCHAR(50),

    debit_amount DECIMAL(18,2),
    credit_amount DECIMAL(18,2),

    source_system TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE Gold.fact_ar (
    invoice_key VARCHAR(50),
    invoice_id TEXT,

    client_key VARCHAR(50),
    customer_key VARCHAR(50),
    currency_key VARCHAR(50),

    invoice_date_key VARCHAR(50),
    due_date_key VARCHAR(50),

    sub_total DECIMAL(18,2),
    discount DECIMAL(18,2),
    net_sales DECIMAL(18,2),
    tax_amount DECIMAL(18,2),
    total_amount DECIMAL(18,2),
    gross_amount DECIMAL(18,2),
    net_cash_flow DECIMAL(18,2),

    source_system TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(invoice_key, invoice_id)
);

CREATE TABLE Gold.fact_invoice_line (

    invoice_line_key VARCHAR(50),
    invoice_key TEXT,

    client_key VARCHAR(50),
    customer_key VARCHAR(50),
    location_key VARCHAR(50),
    product_key VARCHAR(50),

    invoice_date_key VARCHAR(50),

    quantity DECIMAL(18,2),
    unit_price DECIMAL(18,2),

    sub_total DECIMAL(18,2),
    discount DECIMAL(18,2),
    net_sales DECIMAL(18,2),
    tax_amount DECIMAL(18,2),
    total_amount DECIMAL(18,2),
    gross_amount DECIMAL(18,2),
    net_cash_flow DECIMAL(18,2),

    source_system TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(invoice_key, invoice_line_key)
);

COMMIT;