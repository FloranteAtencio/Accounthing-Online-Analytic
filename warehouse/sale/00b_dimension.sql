BEGIN;

CREATE SCHEMA Dimension
DROP TABLE IF EXISTS Dim_customer CASCADE;
CREATE TABLE IF NOT EXISTS Dimension.Dim_customer(

    customer_key key_type NOT NULL,
    customer_id INT NOT NULL,
    customer_groupage age_group_typing NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(customer_key, customer_id)  

);

DROP TABLE IF EXISTS Dim_state CASCADE; 
CREATE TABLE IF NOT EXISTS Dim_state(

    country_key key_type NOT NULL,
    country_id INT NOT NULL,
    country text_typing NOT NULL,
    state text_typing NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(country_key, country_id)

);

DROP TABLE IF EXISTS Dim_date CASCADE;
CREATE TABLE IF NOT EXISTS Dim_date(
    
    date_key key_type NOT NULL,
    date_id INT NOT NULL,
    date DATE NOT NULL,
    day day_typing NOT NULL,
    month month_typing NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date_key,date_id)

);

DROP TABLE IF EXISTS Dim_product CASCADE;
CREATE TABLE IF NOT EXISTS Dim_product(

    product_key key_type NOT NULL,
    product_id INT NOT NULL,
    sub_category sub_category_typing NOT NULL,
    product_category VARCHAR(20) NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_key,product_id)
    
);

COMMIT;

SELECT 'Dimension Schema and Table Complete' AS STATUS;