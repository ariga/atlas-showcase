-- atlas:import ../public.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_event_severity.sql
-- atlas:import ../types/enum_security_event_type.sql

-- create "security_events" table
CREATE TABLE "public"."security_events" (
  "id" serial NOT NULL,
  "event_type" "public"."security_event_type" NOT NULL,
  "severity" "public"."event_severity" NOT NULL,
  "user_id" integer NULL,
  "ip_address" inet NULL,
  "user_agent" text NULL,
  "endpoint" character varying(200) NULL,
  "event_data" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "security_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_security_events_created" to table: "security_events"
CREATE INDEX "idx_security_events_created" ON "public"."security_events" ("created_at" DESC);
-- create index "idx_security_events_ip" to table: "security_events"
CREATE INDEX "idx_security_events_ip" ON "public"."security_events" ("ip_address");
-- create index "idx_security_events_severity" to table: "security_events"
CREATE INDEX "idx_security_events_severity" ON "public"."security_events" ("severity");
-- create index "idx_security_events_user" to table: "security_events"
CREATE INDEX "idx_security_events_user" ON "public"."security_events" ("user_id");
