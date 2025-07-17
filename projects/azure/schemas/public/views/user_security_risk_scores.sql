-- atlas:import ../functions/calculate_security_risk_score.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql
-- atlas:import ../tables/users.sql

-- create "user_security_risk_scores" view
CREATE MATERIALIZED VIEW "public"."user_security_risk_scores" (
  "user_id",
  "email",
  "risk_score",
  "event_types",
  "high_severity_events",
  "last_security_event"
) AS SELECT u.id AS user_id,
    u.email,
    public.calculate_security_risk_score(u.id) AS risk_score,
    count(DISTINCT se.event_type) AS event_types,
    count(se.id) FILTER (WHERE (se.severity = ANY (ARRAY['critical'::public.event_severity, 'high'::public.event_severity]))) AS high_severity_events,
    max(se.created_at) AS last_security_event
   FROM (public.users u
     LEFT JOIN public.security_events se ON (((u.id = se.user_id) AND (se.created_at >= (CURRENT_TIMESTAMP - '30 days'::interval)))))
  GROUP BY u.id, u.email;
-- create index "idx_user_security_risk_scores" to table: "user_security_risk_scores"
CREATE INDEX "idx_user_security_risk_scores" ON "public"."user_security_risk_scores" ("risk_score" DESC);
