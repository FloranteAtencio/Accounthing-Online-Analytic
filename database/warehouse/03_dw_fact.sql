BEGIN;

CREATE TABLE Warehouse.fact_gl (

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


CREATE TABLE Warehouse.fact_ar (
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

CREATE TABLE Warehouse.fact_invoice_line (

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
