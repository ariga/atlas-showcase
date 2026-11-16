-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_deleted_not_null" CHECK (deleted IS NOT NULL);
