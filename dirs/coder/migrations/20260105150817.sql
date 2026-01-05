-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_lifetime_seconds_non_negative" CHECK (lifetime_seconds >= 0);
-- Set comment to column: "shutdown_script_timeout_seconds" on table: "workspace_agents"
COMMENT ON COLUMN "workspace_agents"."shutdown_script_timeout_seconds" IS 'The number of seconds to wait for the shutdown script to complete within this time, the agent lifecycle will be marked as shutdown_timeout.';
