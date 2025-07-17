-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/suppliers.sql

-- create "update_supplier_ratings" function
CREATE FUNCTION "manufacturing"."update_supplier_ratings" ("p_supplier_id" integer, "p_quality_rating" numeric DEFAULT NULL::numeric, "p_delivery_rating" numeric DEFAULT NULL::numeric, "p_cost_rating" numeric DEFAULT NULL::numeric, "p_update_risk_score" boolean DEFAULT true) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    v_new_risk_score NUMERIC(5,2);
    v_current_quality NUMERIC(3,2);
    v_current_delivery NUMERIC(3,2);
    v_current_cost NUMERIC(3,2);
BEGIN
    -- Validate ratings
    IF p_quality_rating IS NOT NULL AND (p_quality_rating < 0 OR p_quality_rating > 5) THEN
        RAISE EXCEPTION 'Quality rating must be between 0 and 5';
    END IF;
    
    IF p_delivery_rating IS NOT NULL AND (p_delivery_rating < 0 OR p_delivery_rating > 5) THEN
        RAISE EXCEPTION 'Delivery rating must be between 0 and 5';
    END IF;
    
    IF p_cost_rating IS NOT NULL AND (p_cost_rating < 0 OR p_cost_rating > 5) THEN
        RAISE EXCEPTION 'Cost rating must be between 0 and 5';
    END IF;
    
    -- Update ratings
    UPDATE manufacturing.suppliers 
    SET 
        quality_rating = COALESCE(p_quality_rating, quality_rating),
        delivery_rating = COALESCE(p_delivery_rating, delivery_rating),
        cost_rating = COALESCE(p_cost_rating, cost_rating),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_supplier_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Supplier with ID % not found', p_supplier_id;
    END IF;
    
    -- Calculate and update risk score if requested
    IF p_update_risk_score THEN
        SELECT quality_rating, delivery_rating, cost_rating
        INTO v_current_quality, v_current_delivery, v_current_cost
        FROM manufacturing.suppliers
        WHERE id = p_supplier_id;
        
        -- Risk score calculation: lower ratings = higher risk
        v_new_risk_score := 100 - (
            (COALESCE(v_current_quality, 2.5) + 
             COALESCE(v_current_delivery, 2.5) + 
             COALESCE(v_current_cost, 2.5)) / 3 * 20
        );
        
        UPDATE manufacturing.suppliers 
        SET risk_score = v_new_risk_score
        WHERE id = p_supplier_id;
    END IF;
END;
$$;
