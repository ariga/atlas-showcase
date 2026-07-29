-- Drop index "idx_audit_logs_resource_type_id" from table: "audit_logs"
DROP INDEX "idx_audit_logs_resource_type_id";
-- Create index "idx_audit_logs_resource_type_id" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_resource_type_id" ON "audit_logs" ("resource_type", "resource_id") WHERE (resource_id IS NOT NULL);
