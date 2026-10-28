-- Modify "organizations" table
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_deleted_not_null" CHECK (deleted IS NOT NULL);
