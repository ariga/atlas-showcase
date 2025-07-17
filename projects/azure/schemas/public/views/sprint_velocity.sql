-- atlas:import ../public.sql
-- atlas:import ../tables/tasks.sql

-- create "sprint_velocity" view
CREATE VIEW "public"."sprint_velocity" (
  "sprint_id",
  "phase_id",
  "sprint_name",
  "start_date",
  "end_date",
  "total_tasks",
  "completed_tasks",
  "completion_rate",
  "completed_hours",
  "actual_hours",
  "velocity_ratio"
) AS WITH sprint_metrics AS (
         SELECT t.sprint_id,
            t.sprint_id AS phase_id,
            'Sprint '::text || t.sprint_id AS sprint_name,
            min(t.start_date) AS start_date,
            max(t.due_date) AS end_date,
            count(DISTINCT t.id) AS total_tasks,
            count(DISTINCT t.id) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_tasks,
            sum(t.estimated_hours) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_hours,
            sum(t.actual_hours) FILTER (WHERE t.status = 'done'::public.task_status) AS actual_hours
           FROM public.tasks t
          WHERE t.sprint_id IS NOT NULL
          GROUP BY t.sprint_id
        )
 SELECT sprint_id,
    phase_id,
    sprint_name,
    start_date,
    end_date,
    total_tasks,
    completed_tasks,
    round(100.0 * completed_tasks::numeric / NULLIF(total_tasks, 0)::numeric, 2) AS completion_rate,
    completed_hours,
    actual_hours,
    round(completed_hours / NULLIF(actual_hours, 0::numeric), 2) AS velocity_ratio
   FROM sprint_metrics
  ORDER BY start_date DESC;
