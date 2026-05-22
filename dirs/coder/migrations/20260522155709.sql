-- Modify "workspace_agents" table
ALTER TABLE "workspace_agents" ADD CONSTRAINT "workspace_agents_startup_logs_length_non_negative" CHECK (startup_logs_length >= 0);
