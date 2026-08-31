SELECT 'Audit table schema start!' as  Status;

BEGIN;

CREATE SCHEMA Audit;
-- ===============================================
-- Audit Area
-- ===============================================

DROP TABLE IF EXISTS Audit.import_sessions CASCADE;
CREATE TABLE Audit.import_sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES Finance.clients(client_id) ON DELETE NO ACTION,
    import_type VARCHAR(50) NOT NULL,  -- 'transactions', 'ar', 'ap', 'inventory','sale' etc.
    imported_by VARCHAR(100) NOT NULL, --  user
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'SUCCESS', 'PARTIAL_SUCCESS', 'FAILED')),
    total_records INT DEFAULT 0,
    successful_records INT DEFAULT 0,
    failed_records INT DEFAULT 0,
    error_summary TEXT,
    source_file VARCHAR(500),
    notes TEXT
);

DROP TABLE IF EXISTS Audit.import_detail_logs CASCADE;
CREATE TABLE Audit.import_detail_logs (
    detail_id BIGSERIAL PRIMARY KEY,
    session_id INT NOT NULL REFERENCES Audit.import_sessions(session_id) ON DELETE NO ACTION,
    row_number INT NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    record_data JSONB NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED', 'SKIPPED', 'WARNED')),
    error_message TEXT,
    warning_message TEXT,
    created_record_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Audit.import_validation_log CASCADE;
CREATE TABLE Audit.import_validation_log (
    validation_id BIGSERIAL PRIMARY KEY,
    session_id INT REFERENCES Audit.import_sessions(session_id) ON DELETE NO ACTION,
    row_number INT NOT NULL,
    field_name VARCHAR(255) NOT NULL,
    validation_rule VARCHAR(255) NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    is_valid BOOLEAN NOT NULL, 
    severity VARCHAR(20) DEFAULT 'ERROR' CHECK (severity IN ('ERROR', 'WARNING', 'INFO')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


COMMIT;

SELECT 'Audit table schema complete!' as  Status;