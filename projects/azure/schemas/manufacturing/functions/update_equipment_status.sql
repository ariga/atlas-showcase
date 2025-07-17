-- atlas:import auto_assign_technician.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../types/enum_equipment_status.sql

-- create "update_equipment_status" function
CREATE FUNCTION "manufacturing"."update_equipment_status" ("p_equipment_id" integer, "p_new_status" "manufacturing"."equipment_status", "p_reason" text DEFAULT NULL::text, "p_updated_by_user_id" integer DEFAULT NULL::integer) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    v_current_status manufacturing.equipment_status;
    v_equipment_name VARCHAR;
    v_production_line_id INTEGER;
    v_auto_work_order_id INTEGER;
BEGIN
    -- Get current equipment details
    SELECT status, name, production_line_id
    INTO v_current_status, v_equipment_name, v_production_line_id
    FROM manufacturing.equipment
    WHERE id = p_equipment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Equipment with ID % not found', p_equipment_id;
    END IF;
    
    -- Don't update if status is the same
    IF v_current_status = p_new_status THEN
        RETURN FALSE;
    END IF;
    
    -- Update equipment status
    UPDATE manufacturing.equipment
    SET 
        status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_equipment_id;
    
    -- Auto-create work order for breakdown status
    IF p_new_status = 'breakdown' THEN
        INSERT INTO manufacturing.maintenance_work_orders (
            work_order_number,
            equipment_id,
            maintenance_type,
            status,
            priority_level,
            title,
            description,
            estimated_hours,
            requested_by_id
        ) VALUES (
            'BREAKDOWN-' || p_equipment_id || '-' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT,
            p_equipment_id,
            'corrective',
            'planned',
            'high',
            'Equipment Breakdown - ' || v_equipment_name,
            'Auto-generated work order for equipment breakdown. Reason: ' || COALESCE(p_reason, 'Not specified'),
            4.0, -- Default 4 hours for breakdown
            p_updated_by_user_id
        ) RETURNING id INTO v_auto_work_order_id;
        
        -- Try to auto-assign a technician for high priority breakdown
        PERFORM manufacturing.auto_assign_technician(v_auto_work_order_id);
    END IF;
    
    -- Update production line status if all equipment is down
    IF p_new_status IN ('breakdown', 'maintenance', 'offline') THEN
        -- Check if all equipment on the line is unavailable
        IF NOT EXISTS (
            SELECT 1 FROM manufacturing.equipment 
            WHERE production_line_id = v_production_line_id 
                AND status IN ('available', 'running', 'idle')
        ) THEN
            UPDATE manufacturing.production_lines
            SET 
                status = 'maintenance',
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_production_line_id;
        END IF;
    END IF;
    
    -- If equipment comes back online, potentially update production line status
    IF p_new_status IN ('available', 'running', 'idle') AND v_current_status IN ('breakdown', 'maintenance', 'offline') THEN
        -- Check if production line can be brought back to running
        IF EXISTS (
            SELECT 1 FROM manufacturing.production_lines pl
            WHERE pl.id = v_production_line_id 
                AND pl.status = 'maintenance'
                AND NOT EXISTS (
                    SELECT 1 FROM manufacturing.equipment e
                    WHERE e.production_line_id = v_production_line_id
                        AND e.status IN ('breakdown', 'offline')
                )
        ) THEN
            UPDATE manufacturing.production_lines
            SET 
                status = 'setup', -- Ready for production but needs setup
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_production_line_id;
        END IF;
    END IF;
    
    RETURN TRUE;
END;
$$;
