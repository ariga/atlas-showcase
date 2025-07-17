-- atlas:import ../manufacturing.sql
-- atlas:import production_lines.sql
-- atlas:import ../types/enum_quality_status.sql
-- atlas:import ../../public/tables/projects.sql
-- atlas:import ../../public/tables/users.sql

-- create "production_runs" table
CREATE TABLE "manufacturing"."production_runs" (
  "id" serial NOT NULL,
  "production_line_id" integer NOT NULL,
  "project_id" integer NULL,
  "assigned_user_id" integer NULL,
  "product_code" character varying(50) NOT NULL,
  "batch_number" character varying(100) NOT NULL,
  "planned_quantity" integer NOT NULL,
  "actual_quantity" integer NULL,
  "quality_status" "manufacturing"."quality_status" NOT NULL DEFAULT 'pending',
  "start_time" timestamptz NULL,
  "end_time" timestamptz NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "yield_percentage" numeric(5,2) NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "production_runs_assigned_user_id_fkey" FOREIGN KEY ("assigned_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "manufacturing"."production_lines" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_actual_quantity_check" CHECK (actual_quantity >= 0),
  CONSTRAINT "production_runs_planned_quantity_check" CHECK (planned_quantity > 0),
  CONSTRAINT "production_runs_time_order" CHECK ((end_time IS NULL) OR (start_time IS NULL) OR (end_time > start_time))
);
