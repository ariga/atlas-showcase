-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql

-- create "schedule_preventive_maintenance" function
CREATE FUNCTION "manufacturing"."schedule_preventive_maintenance" ("p_equipment_id" integer, "p_maintenance_interval_days" integer DEFAULT 90, "p_estimated_hours" numeric DEFAULT 8.0, "p_assigned_technician_id" integer DEFAULT NULL::integer) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_work_order_id INTEGER;
    v_work_order_number VARCHAR;
    v_next_maintenance_date TIMESTAMPTZ;
    v_equipment_name VARCHAR;
BEGIN
    -- Get equipment details
    SELECT name, 
           COALESCE(next_maintenance, CURRENT_TIMESTAMP + INTERVAL '1 day')
    INTO v_equipment_name, v_next_maintenance_date
    FROM manufacturing.equipment 
    WHERE id = p_equipment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Equipment with ID % not found', p_equipment_id;
    END IF;
    
    -- Generate work order number
    v_work_order_number := 'PM-' || p_equipment_id || '-' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT;
    
    -- Create preventive maintenance work order
    INSERT INTO manufacturing.maintenance_work_orders (
        work_order_number,
        equipment_id,
        maintenance_type,
        status,
        priority_level,
        title,
        description,
        assigned_technician_id,
        estimated_hours,
        scheduled_start,
        scheduled_end
    ) VALUES (
        v_work_order_number,
        p_equipment_id,
        'preventive',
        'scheduled',
        'medium',
        'Preventive Maintenance - ' || v_equipment_name,
        'Scheduled preventive maintenance for equipment: ' || v_equipment_name,
        p_assigned_technician_id,
        p_estimated_hours,
        v_next_maintenance_date,
        v_next_maintenance_date + (p_estimated_hours || ' hours')::INTERVAL
    ) RETURNING id INTO v_work_order_id;
    
    -- Update equipment next maintenance date
    UPDATE manufacturing.equipment 
    SET next_maintenance = v_next_maintenance_date + (p_maintenance_interval_days || ' days')::INTERVAL
    WHERE id = p_equipment_id;
    
    RETURN v_work_order_id;
END;
$$;
