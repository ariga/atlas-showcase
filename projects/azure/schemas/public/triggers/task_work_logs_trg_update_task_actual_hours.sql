-- atlas:import ../functions/update_task_actual_hours.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/task_work_logs.sql

-- create trigger "trg_update_task_actual_hours"
CREATE TRIGGER "trg_update_task_actual_hours" AFTER DELETE OR INSERT OR UPDATE ON "public"."task_work_logs" FOR EACH ROW EXECUTE FUNCTION "public"."update_task_actual_hours"();
