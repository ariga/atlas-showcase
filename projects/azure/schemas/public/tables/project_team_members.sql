-- atlas:import ../public.sql
-- atlas:import projects.sql
-- atlas:import users.sql

-- create "project_team_members" table
CREATE TABLE "public"."project_team_members" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "role" character varying(100) NOT NULL,
  "allocation_percentage" integer NOT NULL DEFAULT 100,
  "start_date" date NOT NULL DEFAULT CURRENT_DATE,
  "end_date" date NULL,
  "hourly_rate" numeric(8,2) NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_team_members_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_team_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_team_allocation_valid" CHECK ((allocation_percentage > 0) AND (allocation_percentage <= 100)),
  CONSTRAINT "project_team_dates_valid" CHECK ((end_date IS NULL) OR (end_date >= start_date)),
  CONSTRAINT "project_team_hourly_rate_positive" CHECK ((hourly_rate IS NULL) OR (hourly_rate >= (0)::numeric))
);
-- create index "project_team_active_idx" to table: "project_team_members"
CREATE INDEX "project_team_active_idx" ON "public"."project_team_members" ("project_id", "user_id") WHERE (end_date IS NULL);
-- create index "project_team_project_idx" to table: "project_team_members"
CREATE INDEX "project_team_project_idx" ON "public"."project_team_members" ("project_id");
-- create index "project_team_user_idx" to table: "project_team_members"
CREATE INDEX "project_team_user_idx" ON "public"."project_team_members" ("user_id");
