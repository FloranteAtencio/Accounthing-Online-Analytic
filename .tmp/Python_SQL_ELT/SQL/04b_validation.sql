BEGIN;

-- =============================================================
-- Staging validations END
-- Account Receivables Procedure
-- =============================================================

-- DROP FUNCTION IF EXISTS Compliance.validate_ar_import(INT, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL) CASCADE;
CREATE IF NOT EXISTS FUNCTION Compliance.validate_sale_import(
    p_customer_age INT,
    p_unit_price DECIMAL,
    p_order_quantity INT,
    p_revenue DECIMAL,
    p_unit_cost DECIMAL,
    p_order_quantity INT,
    p_cost DECIMAL,
    p_profit DECIMAL

)
RETURNS TABLE (age_error TEXT, revenue_error TEXT, cost_error TEXT, profit_error TEXT) AS $$
DECLARE

    v_errors_customer_age TEXT;
    v_errors_Revenue TEXT;
    v_errors_cost TEXT;
    v_errors_profit TEXT;
    
BEGIN

    -- Validate age and age group
    IF p_customer_age < 0 OR p_customer_age > 64 THEN
        v_errors_customer_age := 'Kindly Check Age';
    END IF;   
    
    -- finance
    IF p_unit_price * p_order_quantity != p_revenue THEN
        v_errors_Revenue := 'Revenue not match';
    END IF;

    IF p_unit_cost * p_order_quantity != p_cost THEN
        v_errors_cost := 'Cost not match';
    END IF;

    IF p_revenue - p_cost != p_profit THEN
        v_errors_profit := 'Profit not match';    
    END IF;

    RETURN QUERY SELECT
        v_errors_amount,
        v_errors_invoice,
        v_errors_customer,
        v_errors_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

COMMIT;

SELECT 'Part-2 Data Validation Complete' as Status;