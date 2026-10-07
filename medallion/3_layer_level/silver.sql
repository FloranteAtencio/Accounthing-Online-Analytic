SELECT 'Silver table schema start!' as  Status;

BEGIN;

-- ============================================================
-- Silver table or Silver stage 
-- On this layer data are already sanitated and validated 
-- this time record linage only
-- ============================================================
CREATE SCHEMA Silver;
-- 1. STAGING TABLE
CREATE TABLE IF NOT EXISTS Silver.stg_ar_imports(

    invoice_code TEXT,
    customer_code bigint_account_code_type,
    client_code bigint_account_code_type,
    amount amount_type,
    invoice_date DATE,
    due_date DATE,
    status status_typing,
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(invoice_code, customer_code)

);

DROP TABLE IF EXISTS Silver.stg_account;
CREATE TABLE IF NOT EXISTS Silver.stg_account(

    account_key BIGINT,
    account_id INT,
    account_name VARCHAR(50),
    account_type VARCHAR(50),
    account_role VARCHAR(50),
    account_category VARCHAR(50),
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    UNIQUE(account_key, account_id)

);

DROP TABLE IF EXISTS Silver.stg_date;
CREATE TABLE IF NOT EXISTS Silver.stg_date(

    date_key BIGINT,
    date DATE,
    day VARCHAR(50),
    month VARCHAR(50),
    month_name VARCHAR(50),
    quarter VARCHAR(50),
    year VARCHAR(50),
    week VARCHAR(50),
    day_of_week VARCHAR(50),
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date_key,date)

);


-- Client information
DROP TABLE IF EXISTS Silver.stg_client;
CREATE TABLE IF NOT EXISTS Silver.stg_client(

    client_key BIGINT,
    client_id INT,
    client_name TEXT,
    client_type VARCHAR(50),
    industry TEXT,
    country VARCHAR(50),
    region TEXT,
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(client_key,client_id)

);

-- Client information
DROP TABLE IF EXISTS Silver.stg_customer;
CREATE TABLE IF NOT EXISTS Silver.stg_customer(

    customer_key BIGINT,
    customer_id INT,
    customer_name VARCHAR(50),
    customer_type VARCHAR(50),
    industry TEXT,
    country VARCHAR(50),
    region TEXT,
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    UNIQUE(customer_key,customer_id)

);

-- Location information
DROP TABLE IF EXISTS Silver.stg_location;
CREATE TABLE IF NOT EXISTS Silver.stg_location(

    location_key BIGINT,
    location_id INT,
    country TEXT,
    region TEXT,
    province TEXT,
    city TEXT,
    municipality TEXT,
    barangay TEXT,
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(location_key,location_id)

);

DROP TABLE IF EXISTS Silver.stg_currency;
CREATE TABLE IF NOT EXISTS Silver.stg_currency(

    currency_key BIGINT,
    currency_id INT,
    currency_code TEXT,
    currency_name TEXT,
    symbol TEXT,
    validation_status VARCHAR(20) DEFAULT NULL,
    validation_errors TEXT DEFAULT NULL,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(currency_key,currency_id)

);

DROP TABLE IF EXISTS Silver.product;
CREATE TABLE IF NOT EXISTS Silver.product(
    
    product_code INT,
    product_name VARCHAR(50),
    description TEXT,
    product_unit VARCHAR(50),
    quantity INT,
    cost DECIMAL(10,2),
    price DECIMAL(10,2),
    purchase_date date,   
    validation_status TEXT DEFAULT NULL, 
    validation_errors TEXT DEFAULT NULL, 
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    UNIQUE(product_name,product_code)
);

DROP TABLE IF EXISTS Silver.ar_line;
CREATE TABLE IF NOT EXISTS Silver.ar_line(
    
    fact_ar_line_key BIGINT,
	invoice_code TEXT,
    product_code INT,
	quantity INT,
	discount DECIMAL(18,2),
	validation_status TEXT DEFAULT NULL,
	validation_errors TEXT DEFAULT NULL,
	imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(fact_ar_line_key, invoice_code) 
);

COMMIT;

SELECT 'Silver table schema complete!' as  Status;
