-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql

-- create "calculate_project_progress" function
CREATE FUNCTION "public"."calculate_project_progress" ("project_id_param" integer) RETURNS numeric LANGUAGE plpgsql STABLE AS $$
DECLARE
    total_tasks integer;
    completed_tasks integer;
    progress numeric;
BEGIN
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE status = 'done')
    INTO total_tasks, completed_tasks
    FROM tasks
    WHERE project_id = project_id_param;
    
    IF total_tasks > 0 THEN
        progress := ROUND(100.0 * completed_tasks / total_tasks, 2);
    ELSE
        progress := 0;
    END IF;
    
    RETURN progress;
END;
$$;
