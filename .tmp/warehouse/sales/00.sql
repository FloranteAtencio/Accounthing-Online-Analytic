SELECT 'Finance Schema Domain Start!' as  Status;

BEGIN;
-- Account Receivables
-- ======================================================================
-- Special Case 
-- ======================================================================

DROP DOMAIN IF  EXISTS  key_type CASCADE;
CREATE DOMAIN key_type as TEXT
    CONSTRAINT valid_key_type CHECK (VALUE '^[A-Za-z0-9_-]+$')            
-- Email domain
DROP DOMAIN IF EXISTS email_type CASCADE;
CREATE DOMAIN email_type AS VARCHAR(255)
    CONSTRAINT valid_email CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- Phone domain
DROP DOMAIN IF EXISTS phone_type CASCADE;
CREATE DOMAIN phone_type AS VARCHAR(20)
    CONSTRAINT valid_phone CHECK (VALUE ~ '^\+?1?\d{9,15}$' OR VALUE = '');



-- ======================================================================
-- Numeric
-- ======================================================================

-- Amount domain (non-negative)
DROP DOMAIN IF EXISTS amount_type CASCADE;
CREATE DOMAIN amount_type AS DECIMAL(15,2)
    CONSTRAINT positive_amount CHECK (VALUE >= 0);

-- Quantity domain (positive integer)
DROP DOMAIN IF EXISTS quantity_type CASCADE;
CREATE DOMAIN quantity_type AS INT
    CONSTRAINT positive_quantity CHECK (VALUE > 0);

-- Account code domain
DROP DOMAIN IF EXISTS account_code_type CASCADE;
CREATE DOMAIN account_code_type AS INT
    CONSTRAINT valid_account_code CHECK (VALUE > 0);



-- ======================================================================
-- MATCHING 
-- ======================================================================

DROP DOMAIN IF EXISTS charts_typing CASCADE;
CREATE DOMAIN charts_typing AS VARCHAR(50)
    CONSTRAINT valid_charts_typing CHECK ( VALUE IN ('Asset', 'Liability', 'Equity', 'Revenue', 'Expense','Contra Revenue','Contra Asset','Contra Liability','Contra Equity','Contra Expense'));

DROP DOMAIN IF EXISTS action_typing  CASCADE;
CREATE DOMAIN action_typing as  VARCHAR(50)
    CONSTRAINT valid_action_typing CHECK (VALUE IN ('Purchase', 'Sale', 'Sale Return', 'Purchase Return', 'Transfer'));

DROP DOMAIN IF EXISTS status_typing CASCADE;
CREATE DOMAIN status_typing as VARCHAR(50)
    CONSTRAINT valid_status_typing CHECK (VALUE IN ('Pending', 'Paid', 'Overdue','Returned','Partially Returned','Partially Paid'));

DROP DOMAIN IF EXISTS audit_log_typing CASCADE;
CREATE DOMAIN audit_log_typing as VARCHAR(50)
    CONSTRAINT valid_audit_log_typing CHECK (VALUE IN ('INSERT', 'UPDATE', 'DELETE'));


-- Sale
-- ================================================
-- NUMERIC
-- =================================================
DROP DOMAIN IF EXISTS amount_typing CASCADE;
CREATE DOMAIN amount_typing as DECIMAL(19,2)
    CONSTRAINT valid_amount_typing CHECK ( VALUE >= 0);

DROP DOMAIN IF EXISTS num_typing CASCADE;
CREATE DOMAIN num_typing as INT
    CONSTRAINT valid_num_typing CHECK (VALUE >= 0);

DROP DOMAIN IF EXISTS day_typing CASCADE;
CREATE DOMAIN day_typing as INT
    CONSTRAINT valid_day_typing CHECK ( VALUE NOT BETWEEN 1 AND 31);

DROP DOMAIN IF EXISTS year_typing CASCADE;
CREATE DOMAIN year_typing as INT
    CONSTRAINT valid_year_typing CHECK (VALUE NOT BETWEEN 2001 AND 2031);

-- ================================================
-- ALPHA
-- =================================================

DROP DOMAIN IF EXISTS text_typing CASCADE;
CREATE DOMAIN text_typing as VARCHAR(30)
    CONSTRAINT valid_text_typing CHECK (VALUE '^[A-Za-z]+$');

-- ======================================================================
-- MATCHING 
-- ======================================================================

DROP DOMAIN IF EXISTS age_group_typing CASCADE;
CREATE DOMAIN age_group_typing as VARCHAR(30)
    CONSTRAINT valid_age_group_typing CHECK (VALUE IN ('Young Adults (25-34)','Adults (35-64)','Youth (<25)'));

DROP DOMAIN IF EXISTS month_typing CASCADE;
CREATE DOMAIN month_typing as VARCHAR(20)
    CONSTRAINT valid_month_typing CHECK (VALUE IN ('January', 'Febuary', 'March', 'April', 'May','June','July', 'August','September','October','November','December'));

DROP DOMAIN IF EXISTS gender_typing CASCADE;
CREATE DOMAIN gender_typing as CHAR(2)
    CONSTRAINT valid_gender_typing CHECK (VALUE IN ('F','M','f','m','u','U'));

DROP DOMAIN IF EXISTS sub_category_typing CASCADE;
CREATE DOMAIN sub_category_typing as VARCHAR(25)
    CONSTRAINT valid_sub_category_typing CHECK (VALUE IN ('Mountain Bikes','Road Bikes'));

-- ===============================================================
-- SPECIAL CASE
-- ===============================================================

DROP DOMAIN IF EXISTS product_typing CASCADE;
CREATE DOMAIN product_typing as VARCHAR(25)
    CONSTRAINT valid_product_typing CHECK (VALUE !~ '^(Road|Mountain)-\d+(-W)? (Red|Black|Yellow|Silver), \d{2}$' );

COMMIT;
