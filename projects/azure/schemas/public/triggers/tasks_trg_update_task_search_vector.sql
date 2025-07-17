-- atlas:import ../functions/update_task_search_vector.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql

-- create trigger "trg_update_task_search_vector"
CREATE TRIGGER "trg_update_task_search_vector" BEFORE INSERT OR UPDATE OF "description", "tags", "title" ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."update_task_search_vector"();
