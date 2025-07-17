-- atlas:import ../functions/check_security_threshold.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql

-- create trigger "trg_check_security_threshold"
CREATE TRIGGER "trg_check_security_threshold" BEFORE INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."check_security_threshold"();
