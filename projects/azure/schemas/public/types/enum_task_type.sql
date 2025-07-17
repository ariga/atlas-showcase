-- create enum type "task_type"
CREATE TYPE "public"."task_type" AS ENUM ('epic', 'feature', 'story', 'task', 'subtask', 'bug', 'spike', 'improvement');
