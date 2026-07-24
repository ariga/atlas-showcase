-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_updated_at_not_before_created_at" CHECK (updated_at >= created_at);
