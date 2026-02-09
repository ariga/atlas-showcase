-- Create index "idx_audit_logs_user_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_user_time_desc" ON "audit_logs" ("user_id", "time" DESC);
