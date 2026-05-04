-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_url_requires_https" CHECK (url ~~ 'https://%'::text);
