-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_url_requires_http_https_scheme" CHECK (url ~ '^https?://'::text);
