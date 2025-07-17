-- atlas:import ../public.sql
-- atlas:import projects.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_priority_level.sql
-- atlas:import ../types/enum_story_points.sql
-- atlas:import ../types/enum_task_status.sql
-- atlas:import ../types/enum_task_type.sql

-- create "tasks" table
CREATE TABLE "public"."tasks" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "parent_task_id" integer NULL,
  "task_key" character varying(50) NOT NULL,
  "title" character varying(500) NOT NULL,
  "description" text NULL,
  "task_type" "public"."task_type" NOT NULL,
  "status" "public"."task_status" NOT NULL DEFAULT 'backlog',
  "priority" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "story_points" "public"."story_points" NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL DEFAULT 0,
  "remaining_hours" numeric(6,2) NULL,
  "assignee_id" integer NULL,
  "reporter_id" integer NOT NULL,
  "sprint_id" integer NULL,
  "sprint_order" integer NULL,
  "due_date" date NULL,
  "start_date" date NULL,
  "completion_date" date NULL,
  "depends_on" integer[] NULL DEFAULT '{}',
  "blocks" integer[] NULL DEFAULT '{}',
  "labels" text[] NULL DEFAULT '{}',
  "tags" text[] NULL DEFAULT '{}',
  "component" character varying(100) NULL,
  "epic_link" integer NULL,
  "resolution" character varying(100) NULL,
  "environment" character varying(50) NULL,
  "search_vector" tsvector NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "tasks_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_epic_link_fkey" FOREIGN KEY ("epic_link") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_parent_task_id_fkey" FOREIGN KEY ("parent_task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "tasks_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_dates_logical" CHECK (((start_date IS NULL) OR (due_date IS NULL) OR (start_date <= due_date)) AND ((completion_date IS NULL) OR (start_date IS NULL) OR (completion_date >= start_date))),
  CONSTRAINT "tasks_epic_self_reference" CHECK (epic_link <> id),
  CONSTRAINT "tasks_hours_positive" CHECK (((estimated_hours IS NULL) OR (estimated_hours >= (0)::numeric)) AND (actual_hours >= (0)::numeric) AND ((remaining_hours IS NULL) OR (remaining_hours >= (0)::numeric))),
  CONSTRAINT "tasks_key_format" CHECK ((task_key)::text ~ '^[A-Z]+-[0-9]+$'::text),
  CONSTRAINT "tasks_parent_self_reference" CHECK (parent_task_id <> id)
);
-- create index "tasks_assignee_idx" to table: "tasks"
CREATE INDEX "tasks_assignee_idx" ON "public"."tasks" ("assignee_id");
-- create index "tasks_blocks_gin" to table: "tasks"
CREATE INDEX "tasks_blocks_gin" ON "public"."tasks" USING gin ("blocks");
-- create index "tasks_depends_on_gin" to table: "tasks"
CREATE INDEX "tasks_depends_on_gin" ON "public"."tasks" USING gin ("depends_on");
-- create index "tasks_due_date_idx" to table: "tasks"
CREATE INDEX "tasks_due_date_idx" ON "public"."tasks" ("due_date") WHERE (due_date IS NOT NULL);
-- create index "tasks_key_unique" to table: "tasks"
CREATE UNIQUE INDEX "tasks_key_unique" ON "public"."tasks" ("task_key");
-- create index "tasks_labels_gin" to table: "tasks"
CREATE INDEX "tasks_labels_gin" ON "public"."tasks" USING gin ("labels");
-- create index "tasks_parent_task_idx" to table: "tasks"
CREATE INDEX "tasks_parent_task_idx" ON "public"."tasks" ("parent_task_id");
-- create index "tasks_project_id_idx" to table: "tasks"
CREATE INDEX "tasks_project_id_idx" ON "public"."tasks" ("project_id");
-- create index "tasks_search_gin" to table: "tasks"
CREATE INDEX "tasks_search_gin" ON "public"."tasks" USING gin ("search_vector");
-- create index "tasks_sprint_idx" to table: "tasks"
CREATE INDEX "tasks_sprint_idx" ON "public"."tasks" ("sprint_id");
-- create index "tasks_status_idx" to table: "tasks"
CREATE INDEX "tasks_status_idx" ON "public"."tasks" ("status");
-- create index "tasks_tags_gin" to table: "tasks"
CREATE INDEX "tasks_tags_gin" ON "public"."tasks" USING gin ("tags");
