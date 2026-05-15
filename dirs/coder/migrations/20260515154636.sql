-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_rbac_roles_reasonable_size" CHECK (cardinality(rbac_roles) <= 128);
