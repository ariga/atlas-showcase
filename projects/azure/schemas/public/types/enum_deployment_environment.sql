-- create enum type "deployment_environment"
CREATE TYPE "public"."deployment_environment" AS ENUM ('development', 'staging', 'production', 'edge');
