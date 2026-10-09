SELECT 'Bronze table schema start!' as  Status;

BEGIN;

CREATE SCHEMA Bronze;

-- ============================================================
-- Bronze table or Silver stage 
-- On this layer data are already sanitated and validated 
-- this time record linage only
-- ============================================================

-- 1. STAGING TABLE
CREATE TABLE IF NOT EXISTS Bronze.stg_ar_imports(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    invoice_code        TEXT,
    customer_code       TEXT,
    client_code         TEXT,
    amount              TEXT,
    invoice_date        TEXT,
    due_date            TEXT,
    status              TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idempotency_key     TEXT NOT NULL,
    UNIQUE(idempotency_key)
);

DROP TABLE IF EXISTS Bronze.stg_account;
CREATE TABLE IF NOT EXISTS Bronze.stg_account(
    id                  SERIAL PRIMARY KEY,    
    session_id          INT,
    account_key         TEXT,
    account_id          TEXT,
    account_name        TEXT,
    account_type        TEXT,
    account_role        TEXT,
    account_category    TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    UNIQUE(account_key, account_id)

);

DROP TABLE IF EXISTS Bronze.stg_date;
CREATE TABLE IF NOT EXISTS Bronze.stg_date(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    date_key            TEXT,
    date                TEXT,
    day                 TEXT,
    month               TEXT,
    month_name          TEXT,
    quarter             TEXT,
    year                TEXT,
    week                TEXT,
    day_of_week         TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date_key,date)

);


-- Client information
DROP TABLE IF EXISTS Bronze.stg_client;
CREATE TABLE IF NOT EXISTS Bronze.stg_client(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    client_key          TEXT,
    client_id           TEXT,
    client_name         TEXT,
    client_type         TEXT,
    industry            TEXT,
    country             TEXT,
    region              TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(client_key,client_id)

);

-- Client information
DROP TABLE IF EXISTS Bronze.stg_customer;
CREATE TABLE IF NOT EXISTS Bronze.stg_customer(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    customer_key        TEXT,
    customer_id         TEXT,
    customer_name       TEXT,
    customer_type       TEXT,
    industry            TEXT,
    country             TEXT,
    region              TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    UNIQUE(customer_key,customer_id)

);

-- Location information
DROP TABLE IF EXISTS Bronze.stg_location;
CREATE TABLE IF NOT EXISTS Bronze.stg_location(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    location_key        TEXT,
    location_id         TEXT,
    country             TEXT,
    region              TEXT,
    province            TEXT,
    city                TEXT,
    municipality        TEXT,
    barangay            TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(location_key,location_id)

);

DROP TABLE IF EXISTS Bronze.stg_currency;
CREATE TABLE IF NOT EXISTS Bronze.stg_currency(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    currency_key        TEXT,
    currency_id         TEXT,
    currency_code       TEXT,
    currency_name       TEXT,
    symbol              TEXT,
    validation_status   TEXT DEFAULT NULL,
    validation_errors   TEXT DEFAULT NULL,
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(currency_key,currency_id)

);

DROP TABLE IF EXISTS Bronze.product;
CREATE TABLE IF NOT EXISTS Bronze.product(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,    
    product_code        TEXT,
    product_name        TEXT,
    description         TEXT,
    product_unit        TEXT,
    quantity            TEXT,
    cost                TEXT,
    price               TEXT,
    purchase_date       TEXT,   
    validation_status   TEXT DEFAULT NULL, 
    validation_errors   TEXT DEFAULT NULL, 
    imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    UNIQUE(product_name,product_code)
);

DROP TABLE IF EXISTS Bronze.ar_line;
CREATE TABLE IF NOT EXISTS Bronze.ar_line(
    id                  SERIAL PRIMARY KEY,
    session_id          INT,
    client_code         TEXT,
	invoice_code        TEXT,
    product_code        TEXT,
	quantity            TEXT,
	discount            TEXT,
	validation_status   TEXT DEFAULT NULL,
	validation_errors   TEXT DEFAULT NULL,
	imported_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idempotency_key     TEXT,
    UNIQUE(idempotency_key)
);

COMMIT;

SELECT 'Bronze table schema complete!' as  Status;