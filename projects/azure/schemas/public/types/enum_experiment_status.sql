-- create enum type "experiment_status"
CREATE TYPE "public"."experiment_status" AS ENUM ('running', 'completed', 'failed', 'cancelled', 'scheduled');
