BEGIN;

-- ═══════════════════════════════════════════
-- 1. WORM Functions
-- ═══════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit.worm_strict()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'WORM Violation: % on %.% is prohibited',
        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME
        USING ERRCODE = 'insufficient_privilege',
              HINT = 'Audit tables are immutable.';
    RETURN NULL;
END;
$$ SECURITY DEFINER SET search_path = finance, audit, compliance, staging, pg_catalog;

-- Secure override: requires BOTH a GUC flag AND a valid approval record
CREATE OR REPLACE FUNCTION audit.worm_with_exception()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_permission TEXT;
    v_approved   BOOLEAN;
BEGIN
    v_permission := current_setting('app.worm_override', true);

    IF v_permission IS DISTINCT FROM 'true' THEN
        RAISE EXCEPTION 'WORM Override Required for %.%',
            TG_TABLE_SCHEMA, TG_TABLE_NAME
            USING ERRCODE = 'insufficient_privilege';
    END IF;

    -- Verify a real approval exists (not just a session variable)
    SELECT EXISTS (
        SELECT 1 FROM audit.worm_approvals
        WHERE table_name = TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME
          AND approver   = current_setting('app.worm_approver', true)
          AND approved_at > now() - interval '15 minutes'
          AND used = FALSE
    ) INTO v_approved;

    IF NOT v_approved THEN
        RAISE EXCEPTION 'WORM Override rejected: no valid approval for %.%',
            TG_TABLE_SCHEMA, TG_TABLE_NAME
            USING ERRCODE = 'insufficient_privilege';
    END IF;

    -- Mark approval as consumed (single-use token)
    UPDATE audit.worm_approvals
    SET used = TRUE, used_at = now(), used_by = current_user
    WHERE table_name = TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME
      AND approver   = current_setting('app.worm_approver', true)
      AND used = FALSE;

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ SECURITY DEFINER SET search_path = finance, audit, compliance, staging, pg_catalog;

-- ═══════════════════════════════════════════
-- 2. Approval Registry
-- ═══════════════════════════════════════════

CREATE TABLE IF NOT EXISTS audit.worm_approvals (
    approval_id  SERIAL PRIMARY KEY,
    table_name   TEXT        NOT NULL,
    reason       TEXT        NOT NULL,
    approver     TEXT        NOT NULL,
    requested_by TEXT        NOT NULL DEFAULT current_user,
    approved_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at   TIMESTAMPTZ NOT NULL DEFAULT now() + interval '15 minutes',
    used         BOOLEAN     NOT NULL DEFAULT FALSE,
    used_at      TIMESTAMPTZ,
    used_by      TEXT
);

-- ═══════════════════════════════════════════
-- 3. Attach Triggers (Single Source of Truth)
-- ═══════════════════════════════════════════

DO $$
DECLARE
    t TEXT;
    strict_tables TEXT[] := ARRAY[
        'audit.record_lineage',
        'audit.audit_logs',
        'audit.audit_logs_extended',
        'audit.import_detail_logs',
        'audit.reconciliation_tracking',
        'audit.approval_chain',
        'audit.transaction_lifecycle',
        'compliance.compliance_logs',
        'compliance.compliance_rules'
    ];
    exception_tables TEXT[] := ARRAY[
        'audit.import_sessions'
     
    ];
--    'audit.import_validation_log'
BEGIN
    -- Strict: no override possible
    FOREACH t IN ARRAY strict_tables LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS guard_worm ON %s;
             CREATE TRIGGER guard_worm
             BEFORE UPDATE OR DELETE ON %s
             FOR EACH ROW EXECUTE FUNCTION audit.worm_strict();',
            t, t
        );
    END LOOP;

    -- Exception: override requires approval record
    FOREACH t IN ARRAY exception_tables LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS guard_worm ON %s;
             CREATE TRIGGER guard_worm
             BEFORE UPDATE OR DELETE ON %s
             FOR EACH ROW EXECUTE FUNCTION audit.worm_with_exception();',
            t, t
        );
    END LOOP;
END $$;

-- ═══════════════════════════════════════════
-- 4. Block TRUNCATE (triggers don't fire on TRUNCATE)
-- ═══════════════════════════════════════════

DO $$
DECLARE
    t TEXT;
    all_tables TEXT[] := ARRAY[
        'audit.record_lineage','audit.audit_logs','audit.audit_logs_extended',
        'audit.import_detail_logs','audit.reconciliation_tracking',
        'audit.approval_chain','audit.transaction_lifecycle',
        'compliance.compliance_logs','compliance.compliance_rules',
        'audit.import_sessions','audit.import_validation_log'
    ];
BEGIN
    FOREACH t IN ARRAY all_tables LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS guard_worm_truncate ON %s;
             CREATE TRIGGER guard_worm_truncate
             BEFORE TRUNCATE ON %s
             FOR EACH STATEMENT EXECUTE FUNCTION audit.worm_strict();',
            t, t
        );
    END LOOP;
END $$;

-- ═══════════════════════════════════════════
-- 5. Append-Only Optimization
-- ═══════════════════════════════════════════

ALTER TABLE audit.audit_logs SET (fillfactor = 100);

-- ═══════════════════════════════════════════
-- 6. Hash Chain Verification
-- ═══════════════════════════════════════════

CREATE OR REPLACE FUNCTION audit.verify_audit_chain()
RETURNS TABLE(
    row_id         INT,
    is_valid       BOOLEAN,
    expected_hash  TEXT,
    actual_prev_hash TEXT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = audit, pg_catalog
AS $$
BEGIN
    RETURN QUERY
    WITH chain AS (
        SELECT
            audit_id,
            row_hash,
            prev_hash,
            LAG(row_hash) OVER (ORDER BY audit_id) AS last_row_hash
        FROM audit.audit_logs
    )
    SELECT
        audit_id::INT,
        CASE
            WHEN audit_id = (SELECT min(audit_id) FROM audit.audit_logs)
                THEN prev_hash IS NULL          -- genesis must have no prev
            ELSE prev_hash = last_row_hash       -- all others must chain
        END,
        last_row_hash,
        prev_hash
    FROM chain
    ORDER BY audit_id;
END;
$$;

COMMIT;

SELECT 'WORM v2 deployed' AS status;