-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_name_no_surrounding_whitespace" CHECK (name = btrim(name));
