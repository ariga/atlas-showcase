-- Modify "workspace_resources" table
ALTER TABLE "workspace_resources" ADD CONSTRAINT "workspace_resources_daily_cost_non_negative" CHECK (daily_cost >= 0);
