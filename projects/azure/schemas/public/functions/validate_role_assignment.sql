-- atlas:import ../public.sql
-- atlas:import ../tables/user_roles.sql
-- atlas:import ../tables/users.sql

-- create "validate_role_assignment" function
CREATE FUNCTION "public"."validate_role_assignment" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Check if user is active
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = NEW.user_id AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Cannot assign role to inactive user';
    END IF;
    
    -- Check for overlapping role assignments
    IF EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = NEW.user_id
          AND id != COALESCE(NEW.id, 0)
          AND effective_from <= COALESCE(NEW.effective_to, '2099-12-31')
          AND (effective_to IS NULL OR effective_to > NEW.effective_from)
    ) THEN
        RAISE EXCEPTION 'User already has an overlapping role assignment';
    END IF;
    
    RETURN NEW;
END;
$$;
