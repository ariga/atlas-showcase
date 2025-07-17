-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql

-- create "get_project_hierarchy" function
CREATE FUNCTION "public"."get_project_hierarchy" ("project_id_param" integer) RETURNS TABLE ("id" integer, "parent_id" integer, "level" integer, "path" integer[], "name" character varying, "code" character varying) LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE project_tree AS (
    SELECT 
        p.id,
        p.parent_project_id as parent_id,
        0 as level,
        ARRAY[p.id] as path,
        p.name,
        p.code
    FROM projects p
    WHERE p.id = project_id_param
    
    UNION ALL
    
    SELECT 
        p.id,
        p.parent_project_id,
        pt.level + 1,
        pt.path || p.id,
        p.name,
        p.code
    FROM projects p
    JOIN project_tree pt ON p.parent_project_id = pt.id
)
SELECT * FROM project_tree
ORDER BY path;
END;
$$;
