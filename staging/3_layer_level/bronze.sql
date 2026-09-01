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
