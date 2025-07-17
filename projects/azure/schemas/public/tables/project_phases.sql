-- atlas:import ../public.sql
-- atlas:import projects.sql
-- atlas:import ../types/enum_project_status_type.sql

-- create "project_phases" table
CREATE TABLE "public"."project_phases" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "phase_name" character varying(100) NOT NULL,
  "description" text NULL,
  "planned_start" date NOT NULL,
  "planned_end" date NOT NULL,
  "actual_start" date NULL,
  "actual_end" date NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "deliverables" text[] NULL,
  "success_criteria" text[] NULL,
  "phase_order" integer NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_phases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_phases_actual_dates_valid" CHECK ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end >= actual_start)),
  CONSTRAINT "project_phases_dates_valid" CHECK (planned_end >= planned_start),
  CONSTRAINT "project_phases_order_positive" CHECK (phase_order > 0)
);
-- create index "project_phases_project_idx" to table: "project_phases"
CREATE INDEX "project_phases_project_idx" ON "public"."project_phases" ("project_id");
-- create index "project_phases_status_idx" to table: "project_phases"
CREATE INDEX "project_phases_status_idx" ON "public"."project_phases" ("status");
