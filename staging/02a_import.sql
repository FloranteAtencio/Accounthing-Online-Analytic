BEGIN;

CREATE FUNCTION IF NOT EXISTS Staging.sales_import_data(
    p_session_id INT,
    p_sale_order_code TEXT,
    p_sale_date TEXT,
    p_sale_day TEXT,
    p_sale_month TEXT,
    p_sale_year TEXT,
    p_customer_age TEXT,
    p_age_group TEXT,
    p_customer_gender TEXT,
    p_country TEXT,
    p_state TEXT,
    p_product_category TEXT,
    p_sub_category TEXT,
    p_product TEXT,
    p_quantity TEXT,
    p_unit_cost TEXT,
    p_unit_price TEXT,
    p_profit TEXT,
    p_cost TEXT,
    p_revenue TEXT
)
RETURNS INT AS $$
DECLARE
    new_ar_staging_id INT;
BEGIN

    INSERT INTO Staging.stg_ar_imports( 
        session_id,
        sale_order_code,
        sale_date,
        sale_day,
        sale_month,
        sale_year,
        customer_age,
        age_group,
        customer_gender,
        country,
        state,
        product_category,
        sub_category,
        product,
        quantity,
        unit_cost,
        unit_price,
        profit,
        cost,
        revenue,
        validation_status, 
        validation_errors, 
        imported_at
        ) 
    VALUES ( 
        p_session_id,
        p_sale_order_code,
        p_sale_date,
        p_sale_day,
        p_sale_month,
        p_sale_year,
        p_customer_age,
        p_age_group,
        p_customer_gender,
        p_country,
        p_state,
        p_product_category,
        p_sub_category,
        p_product,
        p_quantity,
        p_unit_cost,
        p_unit_price,
        p_profit,
        p_cost,
        p_revenue,
        'DRAFT'
        ,NULL
        ,NOW())
    RETURNING id INTO new_ar_staging_id;

    INSERT INTO Staging.import_workflows
    (session_id, staging_record_id, staging_table,previous_state, new_state, changed_by)
    VALUES(p_session_id, new_ar_staging_id, 'stg_sale_import',NULL, 'DRAFT',current_user);

    RETURN new_ar_staging_id;
END; 
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-1 Data Import Complete' as Status;