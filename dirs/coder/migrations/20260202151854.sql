-- Modify "workspace_apps" table
ALTER TABLE "workspace_apps" ADD CONSTRAINT "workspace_apps_healthcheck_interval_non_negative" CHECK (healthcheck_interval >= 0);
