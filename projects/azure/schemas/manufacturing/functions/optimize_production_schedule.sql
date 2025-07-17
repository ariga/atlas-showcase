-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql
-- atlas:import ../../public/tables/projects.sql

-- create "optimize_production_schedule" function
CREATE FUNCTION "manufacturing"."optimize_production_schedule" ("p_production_line_id" integer, "p_optimization_days" integer DEFAULT 7) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_schedule JSONB := '[]'::JSONB;
    v_current_date DATE := CURRENT_DATE;
    v_line_capacity INTEGER;
    v_daily_schedule JSONB;
    rec RECORD;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour * 24 -- Daily capacity
    INTO v_line_capacity
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Production line with ID % not found', p_production_line_id;
    END IF;
    
    -- Generate optimized schedule for each day
    FOR i IN 0..p_optimization_days-1 LOOP
        v_current_date := CURRENT_DATE + i;
        v_daily_schedule := '[]'::JSONB;
        
        -- Get pending production runs that could be scheduled
        -- Priority: 1) Past due, 2) High priority projects, 3) FIFO
        FOR rec IN (
            WITH pending_runs AS (
                SELECT 
                    pr.*,
                    p.priority_level as project_priority,
                    CASE 
                        WHEN pr.start_time IS NULL THEN 'unscheduled'
                        WHEN pr.start_time < CURRENT_TIMESTAMP THEN 'overdue'
                        ELSE 'scheduled'
                    END as run_status,
                    pr.planned_quantity as remaining_quantity
                FROM manufacturing.production_runs pr
                LEFT JOIN public.projects p ON pr.project_id = p.id
                WHERE pr.production_line_id = p_production_line_id
                    AND pr.end_time IS NULL -- Not completed
                    AND pr.quality_status = 'pending' -- Not yet processed
            )
            SELECT *,
                ROW_NUMBER() OVER (
                    ORDER BY 
                        CASE WHEN run_status = 'overdue' THEN 1 ELSE 2 END,
                        CASE WHEN project_priority = 'high' THEN 1 
                             WHEN project_priority = 'medium' THEN 2 
                             ELSE 3 END,
                        created_at ASC
                ) as priority_rank
            FROM pending_runs
        ) LOOP
            
            -- Check if we have capacity for this run
            IF (v_daily_schedule->'scheduled_quantity')::INTEGER + rec.remaining_quantity <= v_line_capacity THEN
                
                v_daily_schedule := jsonb_set(
                    v_daily_schedule,
                    '{runs}',
                    COALESCE(v_daily_schedule->'runs', '[]'::JSONB) || 
                    jsonb_build_object(
                        'production_run_id', rec.id,
                        'product_code', rec.product_code,
                        'batch_number', rec.batch_number,
                        'planned_quantity', rec.remaining_quantity,
                        'estimated_hours', (rec.remaining_quantity::NUMERIC / (v_line_capacity / 24)),
                        'priority_rank', rec.priority_rank,
                        'project_priority', rec.project_priority
                    )
                );
                
                -- Update scheduled quantity
                v_daily_schedule := jsonb_set(
                    v_daily_schedule,
                    '{scheduled_quantity}',
                    to_jsonb(COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0) + rec.remaining_quantity)
                );
            END IF;
        END LOOP;
        
        -- Add daily schedule metadata
        v_daily_schedule := v_daily_schedule || jsonb_build_object(
            'date', v_current_date,
            'capacity_total', v_line_capacity,
            'capacity_utilized', COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0),
            'capacity_utilization_pct', 
                ROUND((COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0)::NUMERIC / v_line_capacity) * 100, 2),
            'runs_count', jsonb_array_length(COALESCE(v_daily_schedule->'runs', '[]'::JSONB))
        );
        
        -- Add to overall schedule
        v_schedule := v_schedule || v_daily_schedule;
    END LOOP;
    
    -- Return complete optimized schedule
    RETURN jsonb_build_object(
        'production_line_id', p_production_line_id,
        'optimization_period_days', p_optimization_days,
        'schedule_generated_at', CURRENT_TIMESTAMP,
        'daily_schedules', v_schedule,
        'summary', jsonb_build_object(
            'total_runs_scheduled', (
                SELECT SUM(jsonb_array_length(day->'runs'))
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'avg_daily_utilization_pct', (
                SELECT ROUND(AVG((day->>'capacity_utilization_pct')::NUMERIC), 2)
                FROM jsonb_array_elements(v_schedule) as day
            )
        )
    );
END;
$$;
