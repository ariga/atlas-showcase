-- atlas:import ../functions/validate_role_assignment.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/user_roles.sql

-- create trigger "user_roles_validate_trigger"
CREATE TRIGGER "user_roles_validate_trigger" BEFORE INSERT OR UPDATE ON "public"."user_roles" FOR EACH ROW EXECUTE FUNCTION "public"."validate_role_assignment"();
