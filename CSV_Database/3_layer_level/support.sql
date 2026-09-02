BEGIN;

CREATE SCHEMA Support;

CREATE TABLE IF NOT EXISTS Support.import_workflows (
    staging_record_id TEXT, -- id related to table where staging table data record
    staging_table VARCHAR(50), -- staging table
    previous_state VARCHAR(50), -- previous status
    new_state VARCHAR(50), -- current status
    validation_status TEXT DEFAULT 'DRAFT',
    validation_errors TEXT DEFAULT NULL
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    changed_by VARCHAR(100),
);

COMMIT;