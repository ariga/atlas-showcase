-- Create index "idx_audit_logs_resource_type_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_resource_type_time_desc" ON "audit_logs" ("resource_type", "time" DESC) WHERE (resource_type IS NOT NULL);
