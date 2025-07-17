-- atlas:import detect_resource_conflicts.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/gantt_resource_assignments.sql
-- atlas:import ../tables/tasks.sql

-- create "level_resources" function
CREATE FUNCTION "public"."level_resources" ("schedule_id_param" integer) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    conflict_record RECORD;
    task_record RECORD;
    available_capacity numeric;
BEGIN
    -- Process each conflict
    FOR conflict_record IN 
        SELECT * FROM detect_resource_conflicts(schedule_id_param)
        ORDER BY conflict_severity DESC, conflict_date
    LOOP
        available_capacity := 100;
        
        -- Redistribute allocation for conflicting tasks
        FOR task_record IN
            SELECT ra.*
            FROM gantt_resource_assignments ra
            WHERE ra.gantt_task_id = ANY(conflict_record.conflicting_tasks)
                AND ra.user_id = conflict_record.user_id
            ORDER BY ra.allocation_percentage DESC
        LOOP
            IF available_capacity > 0 THEN
                UPDATE gantt_resource_assignments
                SET allocation_percentage = LEAST(task_record.allocation_percentage, available_capacity)
                WHERE id = task_record.id;
                
                available_capacity := available_capacity - LEAST(task_record.allocation_percentage, available_capacity);
            ELSE
                -- Shift task dates if no capacity available
                UPDATE gantt_resource_assignments
                SET start_date = start_date + INTERVAL '1 day',
                    end_date = end_date + INTERVAL '1 day'
                WHERE id = task_record.id;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;
