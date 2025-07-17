-- atlas:import calculate_project_progress.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/project_team_members.sql
-- atlas:import ../tables/tasks.sql

-- create "generate_project_metrics" function
CREATE FUNCTION "public"."generate_project_metrics" ("project_id_param" integer, "as_of_date" date DEFAULT CURRENT_DATE) RETURNS jsonb LANGUAGE plpgsql STABLE AS $$
DECLARE
    metrics jsonb;
BEGIN
    SELECT jsonb_build_object(
        'project_id', project_id_param,
        'as_of_date', as_of_date,
        'completion_percentage', calculate_project_progress(project_id_param),
        'total_tasks', COUNT(*),
        'completed_tasks', COUNT(*) FILTER (WHERE status = 'done'),
        'active_tasks', COUNT(*) FILTER (WHERE status = 'in_progress'),
        'blocked_tasks', COUNT(*) FILTER (WHERE status = 'blocked'),
        'overdue_tasks', COUNT(*) FILTER (WHERE due_date < as_of_date AND status != 'done'),
        'total_estimated_hours', COALESCE(SUM(estimated_hours), 0),
        'total_actual_hours', COALESCE(SUM(actual_hours), 0),
        'team_size', (SELECT COUNT(DISTINCT user_id) FROM project_team_members WHERE project_id = project_id_param AND (end_date IS NULL OR end_date >= CURRENT_DATE))
    ) INTO metrics
    FROM tasks
    WHERE project_id = project_id_param;
    
    RETURN metrics;
END;
$$;
