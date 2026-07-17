-- Create index "idx_audit_logs_org_resource_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_org_resource_time_desc" ON "audit_logs" ("organization_id", "resource_type", "resource_id", "time" DESC);
