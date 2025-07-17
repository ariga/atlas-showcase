-- create enum type "model_status"
CREATE TYPE "public"."model_status" AS ENUM ('development', 'staging', 'production', 'deprecated', 'archived');
