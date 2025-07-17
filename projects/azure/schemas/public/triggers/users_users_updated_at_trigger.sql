-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/users.sql

-- create trigger "users_updated_at_trigger"
CREATE TRIGGER "users_updated_at_trigger" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
