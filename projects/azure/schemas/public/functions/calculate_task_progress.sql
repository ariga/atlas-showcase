-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql

-- create "calculate_task_progress" function
CREATE FUNCTION "public"."calculate_task_progress" ("task_id_param" integer) RETURNS numeric LANGUAGE plpgsql STABLE AS $$
DECLARE
    progress numeric;
    subtask_count integer;
    completed_subtasks integer;
BEGIN
    -- Check if task has subtasks
    SELECT COUNT(*), COUNT(*) FILTER (WHERE status = 'done')
    INTO subtask_count, completed_subtasks
    FROM tasks
    WHERE parent_task_id = task_id_param;
    
    IF subtask_count > 0 THEN
        -- Calculate based on subtasks
        progress := ROUND(100.0 * completed_subtasks / subtask_count, 2);
    ELSE
        -- Use task's own status
        SELECT 
            CASE status
                WHEN 'done' THEN 100
                WHEN 'in_progress' THEN 50
                WHEN 'code_review' THEN 75
                WHEN 'testing' THEN 90
                WHEN 'cancelled' THEN 100
                ELSE 0
            END
        INTO progress
        FROM tasks
        WHERE id = task_id_param;
    END IF;
    
    RETURN COALESCE(progress, 0);
END;
$$;
