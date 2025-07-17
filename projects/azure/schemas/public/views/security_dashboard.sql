-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql
-- atlas:import ../tables/users.sql

-- create "security_dashboard" view
CREATE VIEW "public"."security_dashboard" (
  "date",
  "total_events",
  "unique_users",
  "critical_events",
  "high_events",
  "failed_logins",
  "access_denied",
  "events_by_type"
) AS SELECT date(created_at) AS date,
    count(*) AS total_events,
    count(DISTINCT user_id) AS unique_users,
    count(*) FILTER (WHERE severity = 'critical'::public.event_severity) AS critical_events,
    count(*) FILTER (WHERE severity = 'high'::public.event_severity) AS high_events,
    count(*) FILTER (WHERE event_type = 'login_attempt'::public.security_event_type AND ((event_data ->> 'success'::text)::boolean) = false) AS failed_logins,
    count(*) FILTER (WHERE event_type = 'access_denied'::public.security_event_type) AS access_denied,
    jsonb_object_agg(event_type, type_count) AS events_by_type
   FROM ( SELECT security_events.created_at,
            security_events.user_id,
            security_events.severity,
            security_events.event_type,
            security_events.event_data,
            count(*) OVER (PARTITION BY security_events.event_type) AS type_count
           FROM public.security_events
          WHERE security_events.created_at >= (CURRENT_DATE - '30 days'::interval)) se
  GROUP BY (date(created_at));
