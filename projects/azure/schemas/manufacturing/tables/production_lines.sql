-- atlas:import ../manufacturing.sql
-- atlas:import ../types/enum_production_line_status.sql
-- atlas:import ../../public/tables/projects.sql
-- atlas:import ../../public/tables/users.sql

-- create "production_lines" table
CREATE TABLE "manufacturing"."production_lines" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "description" text NULL,
  "location" character varying(200) NULL,
  "capacity_per_hour" integer NOT NULL,
  "status" "manufacturing"."production_line_status" NOT NULL DEFAULT 'planning',
  "manager_id" integer NULL,
  "project_id" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "last_production_run" timestamptz NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "production_lines_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_lines_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_lines_capacity_per_hour_check" CHECK (capacity_per_hour > 0)
);
