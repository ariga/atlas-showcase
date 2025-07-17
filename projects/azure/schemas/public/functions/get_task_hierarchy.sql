-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql
-- atlas:import ../types/enum_task_status.sql

-- create "get_task_hierarchy" function
CREATE FUNCTION "public"."get_task_hierarchy" ("task_id_param" integer) RETURNS TABLE ("id" integer, "parent_id" integer, "level" integer, "path" integer[], "title" character varying, "task_key" character varying, "status" "public"."task_status") LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE task_tree AS (
    SELECT 
        t.id,
        t.parent_task_id as parent_id,
        0 as level,
        ARRAY[t.id] as path,
        t.title,
        t.task_key,
        t.status
    FROM tasks t
    WHERE t.id = task_id_param
    
    UNION ALL
    
    SELECT 
        t.id,
        t.parent_task_id,
        tt.level + 1,
        tt.path || t.id,
        t.title,
        t.task_key,
        t.status
    FROM tasks t
    JOIN task_tree tt ON t.parent_task_id = tt.id
)
SELECT * FROM task_tree
ORDER BY path;
END;
$$;
