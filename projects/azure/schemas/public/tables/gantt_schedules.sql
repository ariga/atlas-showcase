-- atlas:import ../public.sql
-- atlas:import projects.sql

-- create "gantt_schedules" table
CREATE TABLE "public"."gantt_schedules" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "name" character varying(200) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "critical_path" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "end_date_2" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_schedules_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_gantt_schedules_project" to table: "gantt_schedules"
CREATE INDEX "idx_gantt_schedules_project" ON "public"."gantt_schedules" ("project_id");
