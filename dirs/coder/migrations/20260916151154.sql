-- Modify "organizations" table
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_name_trimmed_non_empty" CHECK ((name = btrim(name)) AND (length(name) > 0));
