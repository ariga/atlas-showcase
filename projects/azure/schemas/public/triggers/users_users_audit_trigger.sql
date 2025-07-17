-- atlas:import ../functions/audit_user_changes.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/users.sql

-- create trigger "users_audit_trigger"
CREATE TRIGGER "users_audit_trigger" AFTER DELETE OR INSERT OR UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."audit_user_changes"();
