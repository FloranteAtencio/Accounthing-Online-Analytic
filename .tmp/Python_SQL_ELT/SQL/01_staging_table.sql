SELECT 'Staging table schema start!' as  Status;

BEGIN;

CREATE SCHEMA Staging;


-- ===============================================
-- Staging Area
-- ===============================================

-- 2. WORKFLOW TABLE
CREATE TABLE IF NOT EXISTS Staging.import_workflows (
    session_id INT, -- id when the loading data or importing 
    staging_record_id BIGINT, -- id related to table where staging table data record
    staging_table VARCHAR(50), -- staging table
    previous_state VARCHAR(50), -- previous status
    new_state VARCHAR(50), -- current status
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 3. APPROVAL TABLE
CREATE TABLE IF NOT EXISTS Staging.import_approvals (
    session_id INT,
    staging_record_id BIGINT,   
    approval_level SMALLINT,
    approval_status VARCHAR(20),
    approved_by VARCHAR(100),
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comments TEXT
);


COMMIT;

SELECT 'Staging table schema complete!' as  Status;