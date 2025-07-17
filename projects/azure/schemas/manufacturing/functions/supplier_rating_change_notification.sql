-- atlas:import update_supplier_ratings.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/supplier_tier_history.sql

-- create "supplier_rating_change_notification" function
CREATE FUNCTION "manufacturing"."supplier_rating_change_notification" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_rating_change NUMERIC;
    v_old_tier VARCHAR;
    v_new_tier VARCHAR;
BEGIN
    -- Calculate tier changes when ratings are updated
    IF NEW.quality_rating != OLD.quality_rating OR 
       NEW.delivery_rating != OLD.delivery_rating OR 
       NEW.cost_rating != OLD.cost_rating THEN
        
        -- Calculate old and new supplier tiers
        v_old_tier := CASE 
            WHEN OLD.quality_rating >= 4.5 AND OLD.delivery_rating >= 4.5 THEN 'preferred'
            WHEN OLD.quality_rating >= 3.5 AND OLD.delivery_rating >= 3.5 THEN 'approved'
            WHEN OLD.quality_rating >= 2.5 OR OLD.delivery_rating >= 2.5 THEN 'conditional'
            ELSE 'review_required'
        END;
        
        v_new_tier := CASE 
            WHEN NEW.quality_rating >= 4.5 AND NEW.delivery_rating >= 4.5 THEN 'preferred'
            WHEN NEW.quality_rating >= 3.5 AND NEW.delivery_rating >= 3.5 THEN 'approved'
            WHEN NEW.quality_rating >= 2.5 OR NEW.delivery_rating >= 2.5 THEN 'conditional'
            ELSE 'review_required'
        END;
        
        -- Log tier changes
        IF v_old_tier != v_new_tier THEN
            INSERT INTO manufacturing.supplier_tier_history (
                supplier_id,
                old_tier,
                new_tier,
                change_date,
                old_quality_rating,
                new_quality_rating,
                old_delivery_rating,
                new_delivery_rating,
                old_cost_rating,
                new_cost_rating
            ) VALUES (
                NEW.id,
                v_old_tier,
                v_new_tier,
                CURRENT_TIMESTAMP,
                OLD.quality_rating,
                NEW.quality_rating,
                OLD.delivery_rating,
                NEW.delivery_rating,
                OLD.cost_rating,
                NEW.cost_rating
            );
        END IF;
        
        -- Auto-update risk score
        PERFORM manufacturing.update_supplier_ratings(NEW.id, NULL, NULL, NULL, TRUE);
    END IF;
    
    RETURN NEW;
END;
$$;
