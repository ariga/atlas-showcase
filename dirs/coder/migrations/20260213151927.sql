-- Create index "idx_audit_logs_request_id" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_request_id" ON "audit_logs" ("request_id") WHERE (request_id IS NOT NULL);
