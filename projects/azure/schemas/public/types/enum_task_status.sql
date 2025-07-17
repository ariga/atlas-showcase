-- create enum type "task_status"
CREATE TYPE "public"."task_status" AS ENUM ('backlog', 'todo', 'in_progress', 'code_review', 'testing', 'blocked', 'done', 'cancelled');
