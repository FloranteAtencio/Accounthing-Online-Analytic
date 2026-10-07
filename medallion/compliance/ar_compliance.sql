
-- Validate AR import
DROP FUNCTION IF EXISTS Compliance.validate_ar_import(INT, INT, DECIMAL, DATE, DATE, VARCHAR) CASCADE;
CREATE FUNCTION Compliance.validate_ar_import(
    p_receivable_id INT,
    p_customer_id INT,
    p_amount DECIMAL,
    p_invoice_date DATE,
    p_due_date DATE,
    p_status VARCHAR
)
RETURNS TABLE (amount_error TEXT, Invoice_error TEXT, customer_error TEXT, status_error TEXT) AS $$
DECLARE

    v_errors_amount TEXT;
    v_errors_invoice TEXT;
    v_errors_customer TEXT;
    v_errors_status TEXT;
    
BEGIN
    -- Validate amount
    IF p_amount <= 0 THEN
        v_errors_amount := 'AR amount must be positive';
    END IF;
    
    -- Validate dates
    IF p_invoice_date > p_due_date THEN
        v_errors_invoice := 'Invoice date cannot be after due date';
    END IF;
    
    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM Finance.customers z WHERE z.customer_id = p_customer_id) THEN
        v_errors_customer := 'Customer ID does not exist';
    END IF;
    
    -- Validate status
    IF p_status NOT IN ('Pending', 'Paid', 'Overdue','Returned','Partially Returned','Partially Paid') THEN
        v_errors_status := 'Invalid AR status';
    END IF;
    
    RETURN QUERY SELECT
        v_errors_amount,
        v_errors_invoice,
        v_errors_customer,
        v_errors_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = Finance, Audit, Compliance, Security, Staging, pg_catalog;
