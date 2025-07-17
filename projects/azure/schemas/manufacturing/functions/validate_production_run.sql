-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql
-- atlas:import ../../public/tables/user_roles.sql
-- atlas:import ../../public/tables/users.sql

-- create "validate_production_run" function
CREATE FUNCTION "manufacturing"."validate_production_run" ("p_production_run_id" integer) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_run RECORD;
    v_line RECORD;
    v_equipment_count INTEGER;
    v_available_equipment INTEGER;
    v_validation_result JSONB;
    v_issues JSONB := '[]'::JSONB;
    v_warnings JSONB := '[]'::JSONB;
    v_is_valid BOOLEAN := TRUE;
BEGIN
    -- Get production run details
    SELECT pr.*, pl.name as line_name, pl.status as line_status, pl.capacity_per_hour
    INTO v_run
    FROM manufacturing.production_runs pr
    JOIN manufacturing.production_lines pl ON pr.production_line_id = pl.id
    WHERE pr.id = p_production_run_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'valid', FALSE,
            'issues', jsonb_build_array('Production run not found')
        );
    END IF;
    
    -- Check production line status
    IF v_run.line_status NOT IN ('running', 'setup') THEN
        v_issues := v_issues || jsonb_build_array(
            'Production line is not operational (status: ' || v_run.line_status || ')'
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check equipment availability
    SELECT 
        COUNT(*),
        COUNT(CASE WHEN status IN ('available', 'running') THEN 1 END)
    INTO v_equipment_count, v_available_equipment
    FROM manufacturing.equipment
    WHERE production_line_id = v_run.production_line_id;
    
    IF v_available_equipment = 0 THEN
        v_issues := v_issues || jsonb_build_array(
            'No equipment available on production line'
        );
        v_is_valid := FALSE;
    ELSIF v_available_equipment < v_equipment_count THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Only ' || v_available_equipment || ' of ' || v_equipment_count || ' equipment units available'
        );
    END IF;
    
    -- Check capacity constraints
    IF v_run.planned_quantity > v_run.capacity_per_hour * 24 THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Planned quantity (' || v_run.planned_quantity || ') exceeds daily capacity (' || 
            (v_run.capacity_per_hour * 24) || ')'
        );
    END IF;
    
    -- Check for scheduling conflicts
    IF EXISTS (
        SELECT 1 FROM manufacturing.production_runs other
        WHERE other.production_line_id = v_run.production_line_id
            AND other.id != v_run.id
            AND other.end_time IS NULL -- Not completed
            AND (
                (v_run.start_time, COALESCE(v_run.end_time, v_run.start_time + INTERVAL '8 hours')) 
                OVERLAPS 
                (other.start_time, COALESCE(other.end_time, other.start_time + INTERVAL '8 hours'))
            )
    ) THEN
        v_issues := v_issues || jsonb_build_array(
            'Scheduling conflict with another production run'
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check material/quality prerequisites
    IF v_run.quality_status NOT IN ('pending', 'pass') THEN
        v_issues := v_issues || jsonb_build_array(
            'Invalid quality status: ' || v_run.quality_status
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check for maintenance windows
    IF EXISTS (
        SELECT 1 FROM manufacturing.maintenance_work_orders wo
        JOIN manufacturing.equipment e ON wo.equipment_id = e.id
        WHERE e.production_line_id = v_run.production_line_id
            AND wo.status IN ('scheduled', 'in_progress')
            AND (v_run.start_time, COALESCE(v_run.end_time, v_run.start_time + INTERVAL '8 hours'))
                OVERLAPS
                (wo.scheduled_start, wo.scheduled_end)
    ) THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Scheduled maintenance may conflict with production window'
        );
    END IF;
    
    -- Check user assignment
    IF v_run.assigned_user_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users u
            JOIN public.user_roles ur ON u.id = ur.user_id
            WHERE u.id = v_run.assigned_user_id
                AND u.status = 'active'
                AND ur.role_type IN ('ENG', 'Tech Lead', 'ENG Manager')
        ) THEN
            v_issues := v_issues || jsonb_build_array(
                'Assigned user is not active or does not have appropriate role'
            );
            v_is_valid := FALSE;
        END IF;
    ELSE
        v_warnings := v_warnings || jsonb_build_array(
            'No user assigned to production run'
        );
    END IF;
    
    -- Build validation result
    v_validation_result := jsonb_build_object(
        'production_run_id', p_production_run_id,
        'valid', v_is_valid,
        'validation_timestamp', CURRENT_TIMESTAMP,
        'issues', v_issues,
        'warnings', v_warnings,
        'equipment_status', jsonb_build_object(
            'total_equipment', v_equipment_count,
            'available_equipment', v_available_equipment,
            'availability_pct', ROUND((v_available_equipment::NUMERIC / NULLIF(v_equipment_count, 0)) * 100, 2)
        ),
        'production_run_details', jsonb_build_object(
            'product_code', v_run.product_code,
            'batch_number', v_run.batch_number,
            'planned_quantity', v_run.planned_quantity,
            'production_line', v_run.line_name,
            'line_status', v_run.line_status
        )
    );
    
    RETURN v_validation_result;
END;
$$;
