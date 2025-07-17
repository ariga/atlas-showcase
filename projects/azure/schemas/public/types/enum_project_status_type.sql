-- create enum type "project_status_type"
CREATE TYPE "public"."project_status_type" AS ENUM ('planning', 'active', 'on_hold', 'testing', 'deployment', 'maintenance', 'completed', 'cancelled', 'archived');
