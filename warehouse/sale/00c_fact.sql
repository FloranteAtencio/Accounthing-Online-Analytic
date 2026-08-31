BEGIN;

CREATE SCHEMA Fact;
CREATE TABLE IF NOT EXIST Fact.Fact_sales(
    -- Identifier
    fact_sales_key BIGSERIAL PRIMARY KEY,
    sales_code key_type NOT NULL,
    
    -- Dimension 
    customer_key key_type NOT NULL,
    location_key key_type NOT NULL,
    date_key key_type NOT NULL,
    product key_type NOT NULL,
    
    -- Measure
    revenue amount_type NOT NULL,
    total_cost amount_type NOT NULL,
    total_unit amount_type NOT NULL,
    profit amount_type NOT NULL,
    unit_price amount_type NOT NULL,
    unit_cost amount_type NOT NULL,
    quantity num_typing,

    -- Meta Data
    age num_typing NOT NULL,
    product product_typing NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(fact_sales_key, sales_code)  
);

COMMIT;
SELECT 'Fact Schema and table Complete' AS STATUS;