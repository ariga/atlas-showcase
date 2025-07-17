-- atlas:import ../public.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_priority_level.sql
-- atlas:import ../types/enum_project_status_type.sql
-- atlas:import ../types/enum_project_type.sql

-- create "projects" table
CREATE TABLE "public"."projects" (
  "id" serial NOT NULL,
  "parent_project_id" integer NULL,
  "code" character varying(20) NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "project_type" "public"."project_type" NOT NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "priority" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "planned_start" date NOT NULL,
  "planned_end" date NOT NULL,
  "actual_start" date NULL,
  "actual_end" date NULL,
  "budget_allocated" numeric(12,2) NULL,
  "budget_spent" numeric(12,2) NULL DEFAULT 0,
  "project_manager_id" integer NULL,
  "tech_lead_id" integer NULL,
  "product_manager_id" integer NULL,
  "tags" text[] NULL DEFAULT '{}',
  "metadata" jsonb NULL DEFAULT '{}',
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "projects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_parent_project_id_fkey" FOREIGN KEY ("parent_project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT "projects_product_manager_id_fkey" FOREIGN KEY ("product_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_project_manager_id_fkey" FOREIGN KEY ("project_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_tech_lead_id_fkey" FOREIGN KEY ("tech_lead_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_actual_dates_valid" CHECK ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end >= actual_start)),
  CONSTRAINT "projects_budget_positive" CHECK ((budget_allocated IS NULL) OR (budget_allocated >= (0)::numeric)),
  CONSTRAINT "projects_budget_spent_valid" CHECK ((budget_spent >= (0)::numeric) AND ((budget_allocated IS NULL) OR (budget_spent <= (budget_allocated * 1.1)))),
  CONSTRAINT "projects_code_format" CHECK ((code)::text ~ '^[A-Z0-9_-]{2,20}$'::text),
  CONSTRAINT "projects_planned_dates_valid" CHECK (planned_end >= planned_start)
);
-- create index "projects_code_unique" to table: "projects"
CREATE UNIQUE INDEX "projects_code_unique" ON "public"."projects" ("code");
-- create index "projects_dates_idx" to table: "projects"
CREATE INDEX "projects_dates_idx" ON "public"."projects" ("planned_start", "planned_end");
-- create index "projects_managers_idx" to table: "projects"
CREATE INDEX "projects_managers_idx" ON "public"."projects" ("project_manager_id", "tech_lead_id", "product_manager_id");
-- create index "projects_metadata_gin" to table: "projects"
CREATE INDEX "projects_metadata_gin" ON "public"."projects" USING gin ("metadata");
-- create index "projects_parent_id_idx" to table: "projects"
CREATE INDEX "projects_parent_id_idx" ON "public"."projects" ("parent_project_id");
-- create index "projects_status_idx" to table: "projects"
CREATE INDEX "projects_status_idx" ON "public"."projects" ("status");
-- create index "projects_tags_gin" to table: "projects"
CREATE INDEX "projects_tags_gin" ON "public"."projects" USING gin ("tags");
-- create index "projects_type_idx" to table: "projects"
CREATE INDEX "projects_type_idx" ON "public"."projects" ("project_type");
