-- atlas:import ../public.sql
-- atlas:import ml_datasets.sql
-- atlas:import ml_models.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_experiment_status.sql
-- atlas:import ../types/enum_model_framework.sql
-- atlas:import ../types/enum_model_task_type.sql

-- create "ml_experiments" table
CREATE TABLE "public"."ml_experiments" (
  "id" serial NOT NULL,
  "experiment_name" character varying(255) NOT NULL,
  "experiment_key" character varying(100) NOT NULL,
  "description" text NULL,
  "model_id" integer NULL,
  "parent_experiment_id" integer NULL,
  "framework" "public"."model_framework" NOT NULL,
  "task_type" "public"."model_task_type" NOT NULL,
  "status" "public"."experiment_status" NOT NULL DEFAULT 'scheduled',
  "training_dataset_id" integer NOT NULL,
  "validation_dataset_id" integer NULL,
  "test_dataset_id" integer NOT NULL,
  "hyperparameters" jsonb NOT NULL DEFAULT '{}',
  "metrics" jsonb NULL DEFAULT '{}',
  "artifacts" jsonb NULL DEFAULT '{}',
  "start_time" timestamptz NULL,
  "end_time" timestamptz NULL,
  "duration_seconds" integer NULL,
  "compute_resources" jsonb NULL,
  "tags" text[] NULL DEFAULT '{}',
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "ml_experiments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_experiments_model_id_fkey" FOREIGN KEY ("model_id") REFERENCES "public"."ml_models" ("id") ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT "ml_experiments_parent_experiment_id_fkey" FOREIGN KEY ("parent_experiment_id") REFERENCES "public"."ml_experiments" ("id") ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT "ml_experiments_test_dataset_id_fkey" FOREIGN KEY ("test_dataset_id") REFERENCES "public"."ml_datasets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_experiments_training_dataset_id_fkey" FOREIGN KEY ("training_dataset_id") REFERENCES "public"."ml_datasets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_experiments_validation_dataset_id_fkey" FOREIGN KEY ("validation_dataset_id") REFERENCES "public"."ml_datasets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_experiments_duration_positive" CHECK ((duration_seconds IS NULL) OR (duration_seconds > 0)),
  CONSTRAINT "ml_experiments_time_order" CHECK ((end_time IS NULL) OR (start_time IS NULL) OR (end_time > start_time))
);
-- create index "ml_experiments_dates_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_dates_idx" ON "public"."ml_experiments" ("start_time", "end_time");
-- create index "ml_experiments_framework_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_framework_idx" ON "public"."ml_experiments" ("framework");
-- create index "ml_experiments_key_unique" to table: "ml_experiments"
CREATE UNIQUE INDEX "ml_experiments_key_unique" ON "public"."ml_experiments" ("experiment_key");
-- create index "ml_experiments_metrics_gin" to table: "ml_experiments"
CREATE INDEX "ml_experiments_metrics_gin" ON "public"."ml_experiments" USING gin ("metrics");
-- create index "ml_experiments_model_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_model_idx" ON "public"."ml_experiments" ("model_id");
-- create index "ml_experiments_status_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_status_idx" ON "public"."ml_experiments" ("status");
-- create index "ml_experiments_tags_gin" to table: "ml_experiments"
CREATE INDEX "ml_experiments_tags_gin" ON "public"."ml_experiments" USING gin ("tags");
