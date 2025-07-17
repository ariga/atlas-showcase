-- atlas:import ../public.sql
-- atlas:import threat_intelligence.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_event_severity.sql
-- atlas:import ../types/enum_incident_status.sql

-- create "security_incidents" table
CREATE TABLE "public"."security_incidents" (
  "id" serial NOT NULL,
  "incident_number" character varying(50) NOT NULL,
  "title" character varying(200) NOT NULL,
  "description" text NULL,
  "severity" "public"."event_severity" NOT NULL,
  "status" "public"."incident_status" NOT NULL DEFAULT 'detected',
  "affected_users" integer[] NULL DEFAULT '{}',
  "affected_systems" text[] NULL DEFAULT '{}',
  "threat_intelligence_id" integer NULL,
  "detected_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "contained_at" timestamptz NULL,
  "resolved_at" timestamptz NULL,
  "assigned_to" integer NULL,
  "resolution_notes" text NULL,
  "lessons_learned" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "security_incidents_incident_number_key" UNIQUE ("incident_number"),
  CONSTRAINT "security_incidents_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "security_incidents_threat_intelligence_id_fkey" FOREIGN KEY ("threat_intelligence_id") REFERENCES "public"."threat_intelligence" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_security_incidents_status" to table: "security_incidents"
CREATE INDEX "idx_security_incidents_status" ON "public"."security_incidents" ("status") WHERE (status <> 'resolved'::public.incident_status);
