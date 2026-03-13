-- Modify "workspace_builds" table
ALTER TABLE "workspace_builds" ADD CONSTRAINT "workspace_builds_daily_cost_non_negative" CHECK (daily_cost >= 0);
