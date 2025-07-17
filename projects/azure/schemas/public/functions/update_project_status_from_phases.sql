-- atlas:import ../public.sql
-- atlas:import ../tables/project_phases.sql
-- atlas:import ../tables/projects.sql

-- create "update_project_status_from_phases" function
CREATE FUNCTION "public"."update_project_status_from_phases" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    active_phases integer;
    completed_phases integer;
    total_phases integer;
BEGIN
    SELECT 
        COUNT(*) FILTER (WHERE status = 'active'),
        COUNT(*) FILTER (WHERE status = 'completed'),
        COUNT(*)
    INTO active_phases, completed_phases, total_phases
    FROM project_phases
    WHERE project_id = NEW.project_id;
    
    -- Update project status based on phase statuses
    IF completed_phases = total_phases AND total_phases > 0 THEN
        UPDATE projects SET status = 'completed' WHERE id = NEW.project_id;
    ELSIF active_phases > 0 THEN
        UPDATE projects SET status = 'active' WHERE id = NEW.project_id;
    END IF;
    
    RETURN NEW;
END;
$$;
