-- atlas:import update_equipment_status.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment_status_log.sql

-- create "equipment_status_change_notification" function
CREATE FUNCTION "manufacturing"."equipment_status_change_notification" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Auto-update equipment status based on changes
    IF NEW.status != OLD.status THEN
        -- Call the equipment status update function to handle cascading logic
        PERFORM manufacturing.update_equipment_status(NEW.id, NEW.status, 'Automated status change', NULL);
        
        -- Log significant status changes
        IF NEW.status IN ('breakdown', 'offline') OR OLD.status IN ('breakdown', 'offline') THEN
            INSERT INTO manufacturing.equipment_status_log (
                equipment_id,
                old_status,
                new_status,
                change_timestamp,
                change_reason
            ) VALUES (
                NEW.id,
                OLD.status,
                NEW.status,
                CURRENT_TIMESTAMP,
                'Automated trigger'
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;
