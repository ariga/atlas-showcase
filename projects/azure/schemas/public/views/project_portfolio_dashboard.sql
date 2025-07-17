-- atlas:import ../public.sql
-- atlas:import ../tables/project_team_members.sql
-- atlas:import ../tables/projects.sql
-- atlas:import ../tables/tasks.sql
-- atlas:import ../tables/users.sql
-- atlas:import ../types/enum_priority_level.sql
-- atlas:import ../types/enum_project_status_type.sql
-- atlas:import ../types/enum_project_type.sql

-- create "project_portfolio_dashboard" view
CREATE VIEW "public"."project_portfolio_dashboard" (
  "id",
  "code",
  "name",
  "project_type",
  "status",
  "priority",
  "planned_start",
  "planned_end",
  "actual_start",
  "actual_end",
  "budget_allocated",
  "budget_spent",
  "budget_utilization",
  "project_manager",
  "tech_lead",
  "total_tasks",
  "completed_tasks",
  "active_tasks",
  "high_priority_tasks",
  "team_size",
  "last_activity"
) AS SELECT p.id,
    p.code,
    p.name,
    p.project_type,
    p.status,
    p.priority,
    p.planned_start,
    p.planned_end,
    p.actual_start,
    p.actual_end,
    p.budget_allocated,
    p.budget_spent,
    round(100.0 * p.budget_spent / NULLIF(p.budget_allocated, 0::numeric), 2) AS budget_utilization,
    (pm_user.first_name::text || ' '::text) || pm_user.last_name::text AS project_manager,
    (tl_user.first_name::text || ' '::text) || tl_user.last_name::text AS tech_lead,
    count(DISTINCT t.id) AS total_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'in_progress'::public.task_status) AS active_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.priority = ANY (ARRAY['high'::public.priority_level, 'critical'::public.priority_level])) AS high_priority_tasks,
    count(DISTINCT tm.user_id) AS team_size,
    max(t.updated_at) AS last_activity
   FROM public.projects p
     LEFT JOIN public.users pm_user ON p.project_manager_id = pm_user.id
     LEFT JOIN public.users tl_user ON p.tech_lead_id = tl_user.id
     LEFT JOIN public.tasks t ON t.project_id = p.id
     LEFT JOIN public.project_team_members tm ON tm.project_id = p.id AND (tm.end_date IS NULL OR tm.end_date >= CURRENT_DATE)
  GROUP BY p.id, p.code, p.name, p.project_type, p.status, p.priority, p.planned_start, p.planned_end, p.actual_start, p.actual_end, p.budget_allocated, p.budget_spent, pm_user.first_name, pm_user.last_name, tl_user.first_name, tl_user.last_name;
