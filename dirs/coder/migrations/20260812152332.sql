-- Modify "organizations" table
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_name_no_surrounding_whitespace" CHECK (name = btrim(name)), ADD CONSTRAINT "organizations_name_not_empty" CHECK (length(btrim(name)) > 0);
