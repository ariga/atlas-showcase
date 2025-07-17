-- atlas:import ../public.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_model_framework.sql
-- atlas:import ../types/enum_model_status.sql
-- atlas:import ../types/enum_model_task_type.sql

-- create "ml_models" table
CREATE TABLE "public"."ml_models" (
  "id" serial NOT NULL,
  "name" character varying(255) NOT NULL,
  "version" character varying(50) NOT NULL,
  "description" text NULL,
  "framework" "public"."model_framework" NOT NULL,
  "task_type" "public"."model_task_type" NOT NULL,
  "status" "public"."model_status" NOT NULL DEFAULT 'development',
  "algorithm" character varying(100) NOT NULL,
  "training_dataset_id" integer NULL,
  "validation_metrics" jsonb NOT NULL DEFAULT '{}',
  "hyperparameters" jsonb NOT NULL DEFAULT '{}',
  "feature_importance" jsonb NULL,
  "model_size_mb" numeric(10,2) NULL,
  "inference_latency_ms" numeric(10,2) NULL,
  "training_duration_hours" numeric(10,2) NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "ml_models_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_models_model_size_positive" CHECK (model_size_mb > (0)::numeric),
  CONSTRAINT "ml_models_version_format" CHECK ((version)::text ~ '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$'::text)
);
-- create index "ml_models_framework_idx" to table: "ml_models"
CREATE INDEX "ml_models_framework_idx" ON "public"."ml_models" ("framework");
-- create index "ml_models_metrics_gin" to table: "ml_models"
CREATE INDEX "ml_models_metrics_gin" ON "public"."ml_models" USING gin ("validation_metrics");
-- create index "ml_models_name_version_unique" to table: "ml_models"
CREATE UNIQUE INDEX "ml_models_name_version_unique" ON "public"."ml_models" ("name", "version");
-- create index "ml_models_status_idx" to table: "ml_models"
CREATE INDEX "ml_models_status_idx" ON "public"."ml_models" ("status");
-- create index "ml_models_task_type_idx" to table: "ml_models"
CREATE INDEX "ml_models_task_type_idx" ON "public"."ml_models" ("task_type");
