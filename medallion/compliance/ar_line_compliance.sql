
-- Validate AR import
DROP FUNCTION IF EXISTS Compliance.validate_ar_line_import(INT, INT, DECIMAL, DATE, DATE, VARCHAR) CASCADE;
CREATE FUNCTION Compliance.validate_ar_import(
    -- p_receivable_id INT,
    p_quantity INT,
    p_discount DECIMAL,
    -- p_invoice_date DATE,
    -- p_due_date DATE,
    -- p_status VARCHAR
)
RETURNS TABLE (quantity_error TEXT, discount_error TEXT) AS $$
DECLARE

    v_errors_quantity TEXT;
    v_errors_discount TEXT;
    -- v_errors_customer TEXT;
    -- v_errors_status TEXT;
    
BEGIN
    -- Validate amount
    IF p_quantity <= 0 THEN
        v_errors_quantity := 'Quantity amount must be positive';
    END IF;
    
    -- Validate dates
    IF p_discount <= 0 THEN
        v_errors_discount := 'Discount amount must be positive';
    END IF;
    
    RETURN QUERY SELECT
        v_errors_discount,
        v_errors_quantity;
        --v_errors_customer,
        --v_errors_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;

