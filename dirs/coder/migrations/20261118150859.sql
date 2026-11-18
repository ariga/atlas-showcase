-- Modify "workspace_proxies" table
ALTER TABLE "workspace_proxies" ADD CONSTRAINT "workspace_proxies_wildcard_hostname_trimmed_non_empty" CHECK ((wildcard_hostname = btrim(wildcard_hostname)) AND (length(btrim(wildcard_hostname)) > 0));
