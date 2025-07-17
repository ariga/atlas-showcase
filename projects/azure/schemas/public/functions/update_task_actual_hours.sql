-- atlas:import ../public.sql
-- atlas:import ../tables/task_work_logs.sql
-- atlas:import ../tables/tasks.sql

-- create "update_task_actual_hours" function
CREATE FUNCTION "public"."update_task_actual_hours" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tasks
    SET actual_hours = (
        SELECT COALESCE(SUM(hours_worked), 0)
        FROM task_work_logs
        WHERE task_id = NEW.task_id
    )
    WHERE id = NEW.task_id;
    
    RETURN NEW;
END;
$$;
