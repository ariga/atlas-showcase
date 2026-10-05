-- Modify "templates" table
ALTER TABLE "templates" ADD CONSTRAINT "templates_max_ttl_non_negative" CHECK (max_ttl >= 0);
