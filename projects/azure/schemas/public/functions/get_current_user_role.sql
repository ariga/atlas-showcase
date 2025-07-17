-- atlas:import ../public.sql
-- atlas:import ../tables/user_roles.sql
-- atlas:import ../types/enum_user_role_type.sql

-- create "get_current_user_role" function
CREATE FUNCTION "public"."get_current_user_role" ("user_id_param" integer) RETURNS "public"."user_role_type" LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT role
        FROM user_roles
        WHERE user_id = user_id_param
          AND effective_from <= CURRENT_DATE
          AND (effective_to IS NULL OR effective_to > CURRENT_DATE)
        ORDER BY effective_from DESC
        LIMIT 1
    );
END;
$$;
