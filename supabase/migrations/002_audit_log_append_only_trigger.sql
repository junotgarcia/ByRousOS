-- ByRousOS · Migration 002
-- Enforce append-only on os.audit_log via trigger
-- Applies to ALL roles including superuser
-- Idempotent: safe to run multiple times

CREATE OR REPLACE FUNCTION os.prevent_audit_log_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'os.audit_log is append-only: UPDATE and DELETE are not allowed';
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_audit_log_mutation ON os.audit_log;

CREATE TRIGGER trg_prevent_audit_log_mutation
BEFORE UPDATE OR DELETE ON os.audit_log
FOR EACH ROW
EXECUTE FUNCTION os.prevent_audit_log_mutation();
