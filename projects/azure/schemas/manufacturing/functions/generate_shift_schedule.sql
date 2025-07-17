-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../../public/tables/user_roles.sql
-- atlas:import ../../public/tables/users.sql

-- create "generate_shift_schedule" function
CREATE FUNCTION "manufacturing"."generate_shift_schedule" ("p_production_line_id" integer, "p_start_date" date DEFAULT CURRENT_DATE, "p_days" integer DEFAULT 7) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_shift_pattern JSONB;
    v_schedule JSONB := '[]'::JSONB;
    v_current_date DATE;
    v_day_schedule JSONB;
    v_line_capacity INTEGER;
    v_technicians JSONB;
    v_shift_count INTEGER;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour INTO v_line_capacity
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Production line with ID % not found', p_production_line_id;
    END IF;
    
    -- Define standard shift pattern (3 shifts, 8 hours each)
    v_shift_pattern := jsonb_build_object(
        'day_shift', jsonb_build_object(
            'start_time', '06:00',
            'end_time', '14:00',
            'shift_code', 'DAY',
            'capacity_factor', 1.0
        ),
        'evening_shift', jsonb_build_object(
            'start_time', '14:00',
            'end_time', '22:00',
            'shift_code', 'EVE',
            'capacity_factor', 0.9
        ),
        'night_shift', jsonb_build_object(
            'start_time', '22:00',
            'end_time', '06:00',
            'shift_code', 'NIGHT',
            'capacity_factor', 0.8
        )
    );
    
    -- Get available technicians
    WITH available_technicians AS (
        SELECT 
            u.id,
            u.first_name || ' ' || u.last_name as name,
            COUNT(wo.id) as current_workload
        FROM public.users u
        LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            AND wo.status IN ('planned', 'scheduled', 'in_progress')
        WHERE u.status = 'active'
            AND EXISTS (
                SELECT 1 FROM public.user_roles ur 
                WHERE ur.user_id = u.id 
                AND ur.role_type IN ('ENG', 'Tech Lead')
            )
        GROUP BY u.id, u.first_name, u.last_name
        ORDER BY current_workload ASC
        LIMIT 12 -- Assume 4 technicians per shift
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'technician_id', id,
            'name', name,
            'workload', current_workload
        )
    ) INTO v_technicians
    FROM available_technicians;
    
    -- Generate schedule for each day
    FOR i IN 0..p_days-1 LOOP
        v_current_date := p_start_date + i;
        v_shift_count := 0;
        
        -- Determine if it''s a weekend (reduced shifts)
        v_shift_count := CASE 
            WHEN EXTRACT(DOW FROM v_current_date) IN (0, 6) THEN 2 -- Weekend: day and evening only
            ELSE 3 -- Weekday: all three shifts
        END;
        
        v_day_schedule := jsonb_build_object(
            'date', v_current_date,
            'day_of_week', EXTRACT(DOW FROM v_current_date),
            'shifts', CASE v_shift_count
                WHEN 3 THEN jsonb_build_array(
                    v_shift_pattern->'day_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->0,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'day_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'evening_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->1,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'evening_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'night_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->2,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'night_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    )
                )
                ELSE jsonb_build_array(
                    v_shift_pattern->'day_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->0,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'day_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'evening_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->1,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'evening_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    )
                )
            END
        );
        
        -- Add daily capacity summary
        v_day_schedule := v_day_schedule || jsonb_build_object(
            'daily_capacity_total', (
                SELECT SUM((shift->>'planned_capacity')::INTEGER)
                FROM jsonb_array_elements(v_day_schedule->'shifts') as shift
            ),
            'shift_count', v_shift_count
        );
        
        v_schedule := v_schedule || v_day_schedule;
    END LOOP;
    
    -- Return complete schedule
    RETURN jsonb_build_object(
        'production_line_id', p_production_line_id,
        'schedule_period', jsonb_build_object(
            'start_date', p_start_date,
            'end_date', p_start_date + p_days - 1,
            'total_days', p_days
        ),
        'shift_pattern', v_shift_pattern,
        'available_technicians', v_technicians,
        'daily_schedules', v_schedule,
        'schedule_generated_at', CURRENT_TIMESTAMP,
        'summary', jsonb_build_object(
            'total_shifts_scheduled', (
                SELECT SUM((day->>'shift_count')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'total_capacity_planned', (
                SELECT SUM((day->>'daily_capacity_total')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'avg_daily_capacity', (
                SELECT AVG((day->>'daily_capacity_total')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            )
        )
    );
END;
$$;
