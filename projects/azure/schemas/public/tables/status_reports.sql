-- atlas:import ../public.sql
-- atlas:import projects.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_project_status_type.sql

-- create "status_reports" table
CREATE TABLE "public"."status_reports" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "reporting_period_start" date NOT NULL,
  "reporting_period_end" date NOT NULL,
  "overall_status" "public"."project_status_type" NOT NULL,
  "summary" text NOT NULL,
  "achievements" text NULL,
  "issues" text NULL,
  "next_steps" text NULL,
  "metrics" jsonb NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "reporting_period_start_2" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "status_reports_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "status_reports_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_status_reports_project" to table: "status_reports"
CREATE INDEX "idx_status_reports_project" ON "public"."status_reports" ("project_id", "reporting_period_end" DESC);
