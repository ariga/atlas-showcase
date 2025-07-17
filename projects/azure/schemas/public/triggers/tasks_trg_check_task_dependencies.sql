-- atlas:import ../functions/check_task_dependencies.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql

-- create trigger "trg_check_task_dependencies"
CREATE TRIGGER "trg_check_task_dependencies" BEFORE UPDATE OF "status" ON "public"."tasks" FOR EACH ROW WHEN (new.status <> old.status) EXECUTE FUNCTION "public"."check_task_dependencies"();
