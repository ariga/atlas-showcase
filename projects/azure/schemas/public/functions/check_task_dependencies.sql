-- atlas:import ../public.sql
-- atlas:import ../tables/task_dependencies.sql
-- atlas:import ../tables/tasks.sql

-- create "check_task_dependencies" function
CREATE FUNCTION "public"."check_task_dependencies" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    dep_status task_status;
BEGIN
    -- Check if all dependencies are completed
    FOR dep_status IN 
        SELECT t.status
        FROM task_dependencies td
        JOIN tasks t ON t.id = td.depends_on_task_id
        WHERE td.task_id = NEW.id
    LOOP
        IF dep_status != 'done' AND NEW.status IN ('in_progress', 'code_review', 'testing', 'done') THEN
            RAISE EXCEPTION 'Cannot progress task: dependencies not completed';
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$;
