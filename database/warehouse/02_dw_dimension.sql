BEGIN;

DROP TABLE IF EXISTS Warehouse.dim_account;
CREATE TABLE IF NOT EXISTS Warehouse.dim_account(

    account_key BIGINT,
    account_id INT,
    account_name VARCHAR(50),
    account_type VARCHAR(50),
    account_role VARCHAR(50),
    account_category VARCHAR(50),
    UNIQUE(account_key, account_id)

);

DROP TABLE IF EXISTS Warehouse.dim_date;
CREATE TABLE IF NOT EXISTS Warehouse.dim_date(

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
DROP TABLE IF EXISTS Warehouse.dim_client;
CREATE TABLE IF NOT EXISTS Warehouse.dim_client(

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
DROP TABLE IF EXISTS Warehouse.dim_customer;
CREATE TABLE IF NOT EXISTS Warehouse.dim_customer(

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
DROP TABLE IF EXISTS Warehouse.dim_location;
CREATE TABLE IF NOT EXISTS Warehouse.dim_location(

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

DROP TABLE IF EXISTS Warehouse.dim_currency;
CREATE TABLE IF NOT EXISTS Warehouse.dim_currency(

    currency_key BIGINT,
    currency_id INT,
    currency_code TEXT,
    currency_name TEXT,
    symbol TEXT,
    UNIQUE(currency_key,currency_id)

);


-- DROP TABLE IF EXISTS Warehouse.invoice_date;
-- CREATE TABLE IF NOT EXISTS Warehouse.invoice_date(

-- invoice_date_key VARCHAR(50),
-- invoice_date_id INT,
-- invoice_date DATE,
-- UNIQUE(invoice_date_key,invoice_date_id)

-- );


-- DROP TABLE IF EXISTS Warehouse.due_date;
-- CREATE TABLE IF NOT EXISTS Warehouse.due_date(
--     due_date_key VARCHAR(50),
--     due_date_id INT,  -- Note: second field should probably be due_date_id
--     due_date DATE,
--     UNIQUE(due_date_key,due_date_id)
-- );

DROP TABLE IF EXISTS Warehouse.product;
CREATE TABLE IF NOT EXISTS Warehouse.product(
    product_key BIGINT,
    product_id INT,
    product_name VARCHAR(50),
    product_line_name VARCHAR(50),
    product_effective Date,
    product_expired date,
    UNIQUE(product_key,product_id)
);

COMMIT;