-- atlas:import ../public.sql
-- atlas:import tasks.sql

-- create "task_dependencies" table
CREATE TABLE "public"."task_dependencies" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "depends_on_task_id" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_dependencies_task_id_depends_on_task_id_key" UNIQUE ("task_id", "depends_on_task_id"),
  CONSTRAINT "task_dependencies_depends_on_task_id_fkey" FOREIGN KEY ("depends_on_task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_dependencies_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_dependencies_check" CHECK (task_id <> depends_on_task_id)
);
-- create index "idx_task_dependencies_depends_on" to table: "task_dependencies"
CREATE INDEX "idx_task_dependencies_depends_on" ON "public"."task_dependencies" ("depends_on_task_id");
-- create index "idx_task_dependencies_task" to table: "task_dependencies"
CREATE INDEX "idx_task_dependencies_task" ON "public"."task_dependencies" ("task_id");
