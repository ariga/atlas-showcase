-- atlas:import ../public.sql

-- create "update_updated_at" function
CREATE FUNCTION "public"."update_updated_at" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
