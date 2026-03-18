-- Modify "audit_logs" table
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_status_code_non_negative" CHECK (status_code >= 0);
