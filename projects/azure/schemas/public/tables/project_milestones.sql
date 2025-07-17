-- atlas:import ../public.sql
-- atlas:import projects.sql
-- atlas:import ../types/enum_project_status_type.sql

-- create "project_milestones" table
CREATE TABLE "public"."project_milestones" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "planned_date" date NOT NULL,
  "actual_date" date NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "milestone_type" character varying(50) NOT NULL DEFAULT 'delivery',
  "dependencies" integer[] NULL DEFAULT '{}',
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_milestones_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- create index "project_milestones_date_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_date_idx" ON "public"."project_milestones" ("planned_date");
-- create index "project_milestones_project_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_project_idx" ON "public"."project_milestones" ("project_id");
-- create index "project_milestones_status_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_status_idx" ON "public"."project_milestones" ("status");
