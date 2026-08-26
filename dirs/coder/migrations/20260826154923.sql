-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_deleted_not_null" CHECK (deleted IS NOT NULL);
