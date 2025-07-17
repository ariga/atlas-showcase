-- atlas:import ../public.sql

-- create "update_task_search_vector" function
CREATE FUNCTION "public"."update_task_search_vector" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'C');
    RETURN NEW;
END;
$$;
