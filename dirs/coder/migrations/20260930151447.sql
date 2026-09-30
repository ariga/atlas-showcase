-- Modify "organizations" table
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_description_trimmed_or_empty" CHECK ((description = ''::text) OR ((description = btrim(description)) AND (length(description) > 0)));
