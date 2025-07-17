-- atlas:import ../public.sql
-- atlas:import ../tables/user_roles.sql
-- atlas:import ../tables/users.sql
-- atlas:import ../types/enum_user_role_type.sql

-- create "role_summary" view
CREATE VIEW "public"."role_summary" (
  "role",
  "total_users",
  "current_users",
  "first_assignment",
  "latest_assignment"
) AS SELECT role,
    count(*) AS total_users,
    count(*) FILTER (WHERE effective_to IS NULL AND effective_from <= CURRENT_DATE) AS current_users,
    min(effective_from) AS first_assignment,
    max(effective_from) AS latest_assignment
   FROM public.user_roles
  GROUP BY role
  ORDER BY role;
