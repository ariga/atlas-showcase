-- atlas:import ../public.sql
-- atlas:import ../tables/gantt_resource_assignments.sql
-- atlas:import ../tables/gantt_tasks.sql
-- atlas:import ../tables/tasks.sql
-- atlas:import ../types/enum_resource_conflict_severity.sql

-- create "detect_resource_conflicts" function
CREATE FUNCTION "public"."detect_resource_conflicts" ("schedule_id_param" integer) RETURNS TABLE ("user_id" integer, "conflict_date" date, "total_allocation" numeric, "conflict_severity" "public"."resource_conflict_severity", "conflicting_tasks" integer[]) LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH daily_allocations AS (
        SELECT 
            ra.user_id,
            d.date,
            SUM(ra.allocation_percentage) as total_allocation,
            array_agg(ra.gantt_task_id) as task_ids
        FROM gantt_resource_assignments ra
        JOIN gantt_tasks gt ON gt.id = ra.gantt_task_id
        CROSS JOIN LATERAL generate_series(ra.start_date, ra.end_date, '1 day'::interval) d(date)
        WHERE gt.schedule_id = schedule_id_param
        GROUP BY ra.user_id, d.date
        HAVING SUM(ra.allocation_percentage) > 100
    )
    SELECT 
        da.user_id,
        da.date::date as conflict_date,
        da.total_allocation,
        CASE 
            WHEN da.total_allocation > 200 THEN 'severe'::resource_conflict_severity
            WHEN da.total_allocation > 150 THEN 'high'::resource_conflict_severity
            WHEN da.total_allocation > 120 THEN 'medium'::resource_conflict_severity
            ELSE 'low'::resource_conflict_severity
        END as conflict_severity,
        da.task_ids as conflicting_tasks
    FROM daily_allocations da
    ORDER BY da.total_allocation DESC, da.date;
END;
$$;
