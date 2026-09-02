SELECT *
FROM (
    SELECT
        TRIM(sale_order_code)   AS sale_order_code,
        TRIM(sale_date)         AS sale_date,
        TRIM(sale_day)          AS sale_day,
        TRIM(sale_month)        AS sale_month,
        TRIM(sale_year)         AS sale_year,
        TRIM(customer_age)      AS customer_age,
        TRIM(age_group)         AS age_group,
        TRIM(customer_gender)   AS customer_gender,
        TRIM(country)           AS country,
        TRIM(state)             AS state,
        TRIM(product_category)  AS product_category,
        TRIM(sub_category)      AS sub_category,
        TRIM(product)           AS product,
        TRIM(quantity)          AS quantity,
        TRIM(unit_cost)         AS unit_cost,
        TRIM(unit_price)        AS unit_price,
        TRIM(product)           AS profit,
        TRIM(cost)              AS cost,
        TRIM(revenue)           AS revenue,
        
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(sale_order_code)
            ORDER BY TRIM(sale_order_code)
        ) AS Uniq
    FROM Bronze.stg_sale_imports a
    JOIN Support.import_workflows b ON a.staging_record_id = a.sale_order_code
    AND b.staging_table = 'Bronze.stg_sale_import'
    AND b.new_state = 'For Posting'
    WHERE invoice_code NOT NULL
) sub;