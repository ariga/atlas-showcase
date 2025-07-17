-- create enum type "deployment_status"
CREATE TYPE "public"."deployment_status" AS ENUM ('deploying', 'active', 'inactive', 'failed', 'rollback');
