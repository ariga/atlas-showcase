-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql
-- atlas:import ../tables/tasks.sql

-- create "task_burndown" view
CREATE VIEW "public"."task_burndown" (
  "date",
  "project_id",
  "project_name",
  "total_created",
  "total_completed",
  "remaining_tasks"
) AS WITH dates AS (
         SELECT generate_series(date_trunc('month'::text, CURRENT_DATE - '3 mons'::interval), CURRENT_DATE::timestamp without time zone, '1 day'::interval)::date AS date
        ), daily_status AS (
         SELECT d.date,
            p.id AS project_id,
            p.name AS project_name,
            count(t.id) FILTER (WHERE t.created_at::date <= d.date) AS total_created,
            count(t.id) FILTER (WHERE t.status = 'done'::public.task_status AND t.updated_at::date <= d.date) AS total_completed,
            count(t.id) FILTER (WHERE t.created_at::date <= d.date AND (t.status <> 'done'::public.task_status OR t.updated_at::date > d.date)) AS remaining_tasks
           FROM dates d
             CROSS JOIN public.projects p
             LEFT JOIN public.tasks t ON t.project_id = p.id
          WHERE p.status = ANY (ARRAY['active'::public.project_status_type, 'testing'::public.project_status_type, 'deployment'::public.project_status_type])
          GROUP BY d.date, p.id, p.name
        )
 SELECT date,
    project_id,
    project_name,
    total_created,
    total_completed,
    remaining_tasks
   FROM daily_status
  WHERE total_created > 0
  ORDER BY project_id, date;
