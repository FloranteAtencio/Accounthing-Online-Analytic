SELECT 'Staging table schema start!' as  Status;

BEGIN;


-- 1. STAGING TABLE
CREATE TABLE IF NOT EXISTS Staging.stg_ar_imports(

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

-- 2. WORKFLOW TABLE
CREATE TABLE IF NOT EXISTS Staging.import_workflows (
    session_id INT,
    staging_record_id BIGINT,
    staging_table VARCHAR(50),
    previous_state VARCHAR(50),
    new_state VARCHAR(50),
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 3. APPROVAL TABLE
CREATE TABLE IF NOT EXISTS Staging.import_approvals (
    session_id INT,
    staging_record_id BIGINT,   

    approval_level SMALLINT,
    approval_status VARCHAR(20),

    approved_by VARCHAR(100),
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    comments TEXT
);


DROP TABLE IF EXISTS Staging.import_sessions CASCADE;
CREATE TABLE Staging.import_sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL, -- REFERENCES Finance.clients(client_id) ON DELETE NO ACTION,
    import_type VARCHAR(50) NOT NULL,  -- 'transactions', 'ar', 'ap', 'inventory', etc.
    imported_by VARCHAR(100) NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'SUCCESS', 'PARTIAL_SUCCESS', 'FAILED')),
    total_records INT DEFAULT 0,
    successful_records INT DEFAULT 0,
    failed_records INT DEFAULT 0,
    error_summary TEXT,
    source_file VARCHAR(500),
    notes TEXT
);

DROP TABLE IF EXISTS Staging.import_detail_logs CASCADE;
CREATE TABLE Staging.import_detail_logs (
    detail_id BIGSERIAL PRIMARY KEY,
    session_id INT NOT NULL, -- REFERENCES Staging.import_sessions(session_id) ON DELETE NO ACTION,
    row_number INT NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    record_data JSONB NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED', 'SKIPPED', 'WARNED')),
    error_message TEXT,
    warning_message TEXT,
    created_record_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Staging.import_validation_log CASCADE;
CREATE TABLE Staging.import_validation_log (
    validation_id BIGSERIAL PRIMARY KEY,
    session_id INT, -- REFERENCES Staging.import_sessions(session_id) ON DELETE NO ACTION,
    row_number INT NOT NULL,
    field_name VARCHAR(255) NOT NULL,
    validation_rule VARCHAR(255) NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    is_valid BOOLEAN NOT NULL,
    severity VARCHAR(20) DEFAULT 'ERROR' CHECK (severity IN ('ERROR', 'WARNING', 'INFO')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS Staging.record_lineage CASCADE;
CREATE TABLE Staging.record_lineage (
    lineage_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    record_id INT NOT NULL,
    client_id INT, --REFERENCES Finance.clients(client_id) ON DELETE NO ACTION,
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN (
        'MANUAL_ENTRY', 'SPREADSHEET_IMPORT', 'API_IMPORT', 
        'SYSTEM_GENERATED', 'CORRECTION', 'REVERSAL'
    )),
    source_file VARCHAR(500),
    import_session_id INT REFERENCES Staging.import_sessions(session_id) ON DELETE NO ACTION,
    import_row_number INT,
    created_by VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified_by VARCHAR(100),
    last_modified_at TIMESTAMP,
    prev_hash TEXT,
    row_hash TEXT,
    is_original BOOLEAN DEFAULT TRUE
);


DROP TABLE IF EXISTS Staging.stg_account;
CREATE TABLE IF NOT EXISTS Staging.stg_account(

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

DROP TABLE IF EXISTS Staging.stg_date;
CREATE TABLE IF NOT EXISTS Staging.stg_date(

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
DROP TABLE IF EXISTS Staging.stg_client;
CREATE TABLE IF NOT EXISTS Staging.stg_client(

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
DROP TABLE IF EXISTS Staging.stg_customer;
CREATE TABLE IF NOT EXISTS Staging.stg_customer(

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
DROP TABLE IF EXISTS Staging.stg_location;
CREATE TABLE IF NOT EXISTS Staging.stg_location(

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

DROP TABLE IF EXISTS Staging.stg_currency;
CREATE TABLE IF NOT EXISTS Staging.stg_currency(

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

DROP TABLE IF EXISTS Staging.product;
CREATE TABLE IF NOT EXISTS Staging.product(
    
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

DROP TABLE IF EXISTS Staging.ar_line;
CREATE TABLE IF NOT EXISTS Staging.ar_line(
    
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

SELECT 'Staging table schema complete!' as  Status;
