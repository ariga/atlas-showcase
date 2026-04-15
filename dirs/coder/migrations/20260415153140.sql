-- Create index "idx_audit_logs_resource_type_id" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_resource_type_id" ON "audit_logs" ("resource_type", "resource_id");
