-- atlas:import ../public.sql
-- atlas:import tasks.sql
-- atlas:import users.sql

-- create "task_comments" table
CREATE TABLE "public"."task_comments" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "comment" text NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_comments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_task_comments_task" to table: "task_comments"
CREATE INDEX "idx_task_comments_task" ON "public"."task_comments" ("task_id");
-- create index "idx_task_comments_user" to table: "task_comments"
CREATE INDEX "idx_task_comments_user" ON "public"."task_comments" ("user_id");
