-- Create index "workspace_proxies_lower_url_idx" to table: "workspace_proxies"
CREATE UNIQUE INDEX "workspace_proxies_lower_url_idx" ON "workspace_proxies" ((lower(url))) WHERE (deleted = false);
