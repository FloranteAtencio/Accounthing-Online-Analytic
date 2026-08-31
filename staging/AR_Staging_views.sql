BEGIN;

-- ============================================================
-- Staging table or Silver stage 
-- On this layer another transformation process will be made
-- ============================================================

CREATE VIEW Staging.fact_ar_view AS
SELECT 
    invoice_code
    ,customer_code
    ,client_code
    ,amount
    ,invoice_date
    ,due_date
    ,status
    ,(amount * 0.10) AS tax_amount
    ,(amount * 0.10) + amount AS gross_amount
FROM Staging.stg_ar_imports
CREATE VIEW general_ledger_view AS 
    ---account receivables
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Account Receivables' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        (SELECT round(sum( (((p.price - (p.price * al.discount)) + ((p.price - (p.price * al.discount)) * 0.10)) * al.quantity ) ),2) FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'
    FROM Staging.stg_ar_imports sai
    UNION ALL
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Sales Revenue' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        round((((p.price - (p.price * al.discount)) + ((p.price - (p.price * al.discount)) * 0.10)) * al.quantity ),2) as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.Staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    UNION ALL
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Tax Payable' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        (SELECT round(sum( (((p.price - (p.price * al.discount)) * al.quantity) * 0.10 ) ),2) FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as credit_amount,
        'CSV_Import'
    FROM Staging.stg_ar_imports sai
    --WHERE sai.status IN ('pending','paid','partially paid');
    UNION ALL
    --- =====================================================
    -- Account Receivables
    -- discount
    --- =====================================================
    -- ar discount
    SELECT 

        format('Invoice - %s (%s) ',sai.invoice_code, p.product_name) as transaction,
        'Account Receivables' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        round(((p.price * al.discount) * al.quantity ),2) as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    WHERE al.discount > 0
    UNION ALL
    -- Sales Discount
    SELECT 

        format('Invoice - %s (%s) ',sai.invoice_code, p.product_name) as transaction,
        'Sales Discount' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        round(((p.price * al.discount) * al.quantity ),2) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    WHERE al.discount > 0
    UNION ALL
    --- =====================================================
    -- account receivable
    -- cash/bank
    --- =====================================================
    -- Payment AR
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Account Receivables' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        sai.amount as credit_amount,
    --    round(((p.price * al.discount) * al.quantity ),2) as credit_amount,
        'CSV_Import'
    FROM Staging.stg_ar_imports sai
    -- LEFT JOIN staging.ar_line al USING(invoice_code)
    -- LEFT JOIN staging.product p USING(product_code)
    WHERE sai.amount > 0
    UNION ALL
    --sai.status IN ('pending','paid','partially paid') and 
    -- PAYMENT CASH
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Cash/Bank' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        sai.amount as debit_amount,
    --    round(((p.price * al.discount) * al.quantity ),2) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    -- LEFT JOIN staging.ar_line al USING(invoice_code)
    -- LEFT JOIN staging.product p USING(product_code)
    WHERE sai.amount > 0
    UNION ALL
    --- =====================================================
    -- COST OF GOOD SOLE 
    -- INVENTORY
    --- ====================================================
    SELECT 
        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Cost Of Good Sold' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        (SELECT round(sum(  p.cost * al.quantity),2 )FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as debit_amount,    
    --    (SELECT round(sum( (((p.price - (p.price * al.discount)) + ((p.price - (p.price * al.discount)) * 0.10)) * al.quantity ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'
    FROM Staging.stg_ar_imports sai
    UNION ALL
    -- WHERE sai.status IN ('pending','paid','partially paid');
    SELECT 
        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Inventory' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        (SELECT round( sum(  p.cost * al.quantity  ),2 )FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as credit_amount,    
    --    (SELECT round(sum( (((p.price - (p.price * al.discount)) * al.quantity) * 0.10 ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as credit_amount,
        'CSV_Import'
    FROM Staging.stg_ar_imports sai
    -- WHERE sai.status IN ('pending','paid','partially paid');
    UNION ALL
    --- ========================================================
    --- RETURNS
    --- ========================================================
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Account Receivables' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        (SELECT round(sum( (((p.price - (p.price * al.discount)) + ((p.price - (p.price * al.discount)) * 0.10)) * al.quantity ) ),2) FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    WHERE sai.status IN ('returned')
    UNION ALL
    --WHERE sai.status IN ('pending','paid','partially paid');
    --sales revenue
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Sales Returns and Allowances' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        round((((p.price - (p.price * al.discount)) + ((p.price - (p.price * al.discount)) * 0.10)) * al.quantity ),2) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    WHERE sai.status IN ('returned')
    UNION ALL
    --WHERE sai.status IN ('pending','paid','partially paid');
    --Tax Payable
    SELECT 

        format('Invoice - %s ',sai.invoice_code) as transaction,
        'Tax Payable' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
    --    0.00 as debit_amount,
        (SELECT round(sum( (((p.price - (p.price * al.discount)) * al.quantity) * 0.10 ) ),2) FROM Staging.ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as debit_amount,
        0.00 as credit_amount,  
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    WHERE sai.status IN ('returned')
    UNION ALL
    --- =====================================================
    -- account receivable
    -- cash/bank
    --- =====================================================
    -- Payment AR
    SELECT 

        format('Invoice - %s',sai.invoice_code) as transaction,
        'Account Payable (Customer Refund)' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        sai.amount as debit_amount,
        0.00 as cred_amount,
    --    round(((p.price * al.discount) * al.quantity ),2) as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    -- LEFT JOIN staging.ar_line al USING(invoice_code)
    -- LEFT JOIN staging.product p USING(product_code)
    WHERE sai.amount > 0 and sai.status IN ('returned')
    UNION ALL
    --sai.status IN ('pending','paid','partially paid') and 
    -- PAYMENT CASH
    SELECT 

        format('Invoice - %s',sai.invoice_code ) as transaction,
        'Cash/Bank' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        0.00 as debit_amount,
        sai.amount as credit_amount,
    --    round(((p.price * al.discount) * al.quantity ),2) as debit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    -- LEFT JOIN staging.ar_line al USING(invoice_code)
    -- LEFT JOIN staging.product p USING(product_code)
    WHERE sai.amount > 0 and sai.status IN ('returned')
    UNION ALL
    -- ar discount
    SELECT 

        format('Invoice - %s (%s) ',sai.invoice_code, p.product_name) as transaction,
        'Account Receivables' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        round(((p.price * al.discount) * al.quantity ),2) as debit_amount,
        0.00 as credit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    WHERE al.discount > 0 and sai.status IN ('returned')
    -- Sales Discoun
    UNION ALL
    SELECT 

        format('Invoice - %s (%s) ',sai.invoice_code, p.product_name) as transaction,
        'Sales Discount' as account_key,
        sai.client_code as  client_key,
        sai.invoice_date as journal_date_key,
        round(((p.price * al.discount) * al.quantity ),2) as credit_amount,
        0.00 as debit_amount,
        'CSV_Import'

    FROM Staging.stg_ar_imports sai
    LEFT JOIN staging.ar_line al USING(invoice_code)
    LEFT JOIN staging.product p USING(product_code)
    WHERE al.discount > 0 and sai.status IN ('returned');

    --sai.status IN ('pending','paid','partially paid') and sai.amount > 0;

        -- (SELECT round(sum( ((p.price - (p.price * al.discount) - p.cost) * al.quantity ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as net_profit_or_gross_amount,
        -- (SELECT round(sum( (((p.price - (p.price * al.discount) + ( p.price - (p.price * al.discount) * 0.10))  - p.cost - ( p.price - (p.price * al.discount) * 0.10) ) * al.quantity ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as net_cash_flow
        -- (SELECT round(sum( (p.price * al.quantity) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as sub_total,
        -- (SELECT round(sum( ((p.price * al.discount) * al.quantity ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as discount,
        -- (SELECT round(sum( ((p.price - (p.price * al.discount)) * al.quantity ) ),2) FROM ar_line al LEFT JOIN Staging.product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as net_sales,    
        -- (SELECT round(sum( (((p.price - (p.price * al.discount)) * al.quantity) * 0.10 ) ),2) FROM ar_line al LEFT JOIN product p USING(product_code) WHERE al.invoice_code = sai.invoice_code ) as tax_amount,

COMMIT;
