-- Modify "workspace_agents" table
ALTER TABLE "workspace_agents" ADD CONSTRAINT "workspace_agents_connection_timeout_seconds_non_negative" CHECK (connection_timeout_seconds >= 0);
