-- Drop index "idx_audit_logs_org_time_desc" from table: "audit_logs"
DROP INDEX "idx_audit_logs_org_time_desc";
-- Drop index "idx_audit_logs_time_desc" from table: "audit_logs"
DROP INDEX "idx_audit_logs_time_desc";
-- Drop index "idx_audit_logs_user_time_desc" from table: "audit_logs"
DROP INDEX "idx_audit_logs_user_time_desc";
-- Modify "audit_logs" table
ALTER TABLE "audit_logs" DROP COLUMN "time", ADD COLUMN "occurred_at" timestamptz NOT NULL;
-- Create index "idx_audit_logs_org_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_org_time_desc" ON "audit_logs" ("organization_id", "occurred_at" DESC);
-- Create index "idx_audit_logs_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_time_desc" ON "audit_logs" ("occurred_at" DESC);
-- Create index "idx_audit_logs_user_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_user_time_desc" ON "audit_logs" ("user_id", "occurred_at" DESC);
