SELECT 'Staging table schema start!' as  Status;

BEGIN;

-- ============================================================
-- Staging table or Bronse stage 
-- On this layer data are need to sanitize, validation and approval
-- On this audit, compliance record linage  and monitoring will on line
-- ============================================================

-- ===============================================
-- Staging Area
-- ===============================================

-- 1. STAGING TABLE
CREATE TABLE IF NOT EXISTS Staging.stg_sale_imports(
    -- id BIGSERIAL PRIMARY KEY,
    -- session_id INT NOT NULL, -- id when the loading data or importing
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
    revenue TEXT NOT NULL,
    
    -- meta data
    validation_status TEXT,
    validation_errors TEXT,
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sale_order_code)
);

COMMIT;

SELECT 'Staging table schema complete!' as  Status;