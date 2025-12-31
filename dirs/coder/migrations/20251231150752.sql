-- Modify "workspaces" table
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_ttl_non_negative" CHECK ((ttl IS NULL) OR (ttl >= 0));
