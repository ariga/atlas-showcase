-- atlas:import ../public.sql
-- atlas:import ml_models.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_deployment_environment.sql
-- atlas:import ../types/enum_deployment_status.sql

-- create "ml_model_deployments" table
CREATE TABLE "public"."ml_model_deployments" (
  "id" serial NOT NULL,
  "model_id" integer NOT NULL,
  "deployment_name" character varying(255) NOT NULL,
  "environment" "public"."deployment_environment" NOT NULL,
  "status" "public"."deployment_status" NOT NULL DEFAULT 'deploying',
  "endpoint_url" text NULL,
  "version_tag" character varying(100) NOT NULL,
  "replica_count" integer NOT NULL DEFAULT 1,
  "cpu_limit" numeric(5,2) NULL,
  "memory_limit_gb" numeric(5,2) NULL,
  "gpu_enabled" boolean NOT NULL DEFAULT false,
  "gpu_count" integer NULL DEFAULT 0,
  "autoscaling_enabled" boolean NOT NULL DEFAULT false,
  "min_replicas" integer NULL DEFAULT 1,
  "max_replicas" integer NULL DEFAULT 10,
  "target_qps" integer NULL,
  "monitoring_config" jsonb NULL DEFAULT '{}',
  "deployment_config" jsonb NULL DEFAULT '{}',
  "health_check_url" text NULL,
  "last_health_check" timestamptz NULL,
  "deployed_at" timestamptz NULL,
  "deployed_by" integer NOT NULL,
  "retired_at" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "ml_model_deployments_deployed_by_fkey" FOREIGN KEY ("deployed_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_model_deployments_model_id_fkey" FOREIGN KEY ("model_id") REFERENCES "public"."ml_models" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "ml_deployments_autoscaling_valid" CHECK ((NOT autoscaling_enabled) OR (min_replicas <= max_replicas)),
  CONSTRAINT "ml_deployments_gpu_valid" CHECK ((NOT gpu_enabled) OR (gpu_count > 0)),
  CONSTRAINT "ml_deployments_replica_count_positive" CHECK (replica_count > 0),
  CONSTRAINT "ml_deployments_resources_positive" CHECK (((cpu_limit IS NULL) OR (cpu_limit > (0)::numeric)) AND ((memory_limit_gb IS NULL) OR (memory_limit_gb > (0)::numeric)))
);
-- create index "ml_deployments_active_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_active_idx" ON "public"."ml_model_deployments" ("status", "environment") WHERE (status = 'active'::public.deployment_status);
-- create index "ml_deployments_environment_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_environment_idx" ON "public"."ml_model_deployments" ("environment");
-- create index "ml_deployments_model_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_model_idx" ON "public"."ml_model_deployments" ("model_id");
-- create index "ml_deployments_name_env_unique" to table: "ml_model_deployments"
CREATE UNIQUE INDEX "ml_deployments_name_env_unique" ON "public"."ml_model_deployments" ("deployment_name", "environment");
-- create index "ml_deployments_status_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_status_idx" ON "public"."ml_model_deployments" ("status");
