-- Add new schema named "manufacturing"
CREATE SCHEMA "manufacturing";
-- Create enum type "sensor_type"
CREATE TYPE "public"."sensor_type" AS ENUM ('temperature', 'humidity', 'pressure', 'motion', 'light', 'air_quality', 'water_level', 'power_consumption');
-- Create "iot_sensor_types" table
CREATE TABLE "public"."iot_sensor_types" (
  "id" serial NOT NULL,
  "sensor_type" "public"."sensor_type" NOT NULL,
  "unit" character varying(20) NOT NULL,
  "min_value" numeric NULL,
  "max_value" numeric NULL,
  "precision" integer NULL DEFAULT 2,
  "alert_thresholds" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);
-- Create "check_sensor_anomaly" function
CREATE FUNCTION "public"."check_sensor_anomaly" ("p_device_id" integer, "p_sensor_type" "public"."sensor_type", "p_value" numeric) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    v_threshold JSONB;
    v_min_value DECIMAL;
    v_max_value DECIMAL;
BEGIN
    SELECT alert_thresholds, min_value, max_value
    INTO v_threshold, v_min_value, v_max_value
    FROM iot_sensor_types
    WHERE sensor_type = p_sensor_type;
    
    IF p_value < v_min_value OR p_value > v_max_value THEN
        RETURN TRUE;
    END IF;
    
    IF v_threshold IS NOT NULL THEN
        IF p_value < (v_threshold->>'critical_min')::DECIMAL OR 
           p_value > (v_threshold->>'critical_max')::DECIMAL THEN
            RETURN TRUE;
        END IF;
    END IF;
    
    RETURN FALSE;
END;
$$;
-- Create enum type "story_points"
CREATE TYPE "public"."story_points" AS ENUM ('1', '2', '3', '5', '8', '13', '21', '34', '55', '89');
-- Create enum type "priority_level"
CREATE TYPE "public"."priority_level" AS ENUM ('critical', 'high', 'medium', 'low');
-- Create enum type "task_type"
CREATE TYPE "public"."task_type" AS ENUM ('epic', 'feature', 'story', 'task', 'subtask', 'bug', 'spike', 'improvement');
-- Create enum type "user_status_type"
CREATE TYPE "public"."user_status_type" AS ENUM ('active', 'inactive', 'archived');
-- Create "users" table
CREATE TABLE "public"."users" (
  "id" serial NOT NULL,
  "email" character varying(255) NOT NULL,
  "first_name" character varying(100) NOT NULL,
  "last_name" character varying(100) NOT NULL,
  "phone" character varying(20) NULL,
  "hire_date" date NOT NULL DEFAULT CURRENT_DATE,
  "status" "public"."user_status_type" NOT NULL DEFAULT 'active',
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_email_valid" CHECK ((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text),
  CONSTRAINT "users_hire_date_reasonable" CHECK ((hire_date >= '1990-01-01'::date) AND (hire_date <= (CURRENT_DATE + '1 year'::interval))),
  CONSTRAINT "users_name_not_empty" CHECK ((length(TRIM(BOTH FROM first_name)) > 0) AND (length(TRIM(BOTH FROM last_name)) > 0))
);
-- Create index "users_email_unique" to table: "users"
CREATE UNIQUE INDEX "users_email_unique" ON "public"."users" ("email");
-- Create index "users_hire_date_idx" to table: "users"
CREATE INDEX "users_hire_date_idx" ON "public"."users" ("hire_date");
-- Create index "users_status_idx" to table: "users"
CREATE INDEX "users_status_idx" ON "public"."users" ("status");
-- Create enum type "task_status"
CREATE TYPE "public"."task_status" AS ENUM ('backlog', 'todo', 'in_progress', 'code_review', 'testing', 'blocked', 'done', 'cancelled');
-- Create enum type "project_status_type"
CREATE TYPE "public"."project_status_type" AS ENUM ('planning', 'active', 'on_hold', 'testing', 'deployment', 'maintenance', 'completed', 'cancelled', 'archived');
-- Create enum type "project_type"
CREATE TYPE "public"."project_type" AS ENUM ('web_app', 'mobile_app', 'embedded_system', 'infrastructure', 'data_platform', 'api_service', 'research');
-- Create "projects" table
CREATE TABLE "public"."projects" (
  "id" serial NOT NULL,
  "parent_project_id" integer NULL,
  "code" character varying(20) NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "project_type" "public"."project_type" NOT NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "priority" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "planned_start" date NOT NULL,
  "planned_end" date NOT NULL,
  "actual_start" date NULL,
  "actual_end" date NULL,
  "budget_allocated" numeric(12,2) NULL,
  "budget_spent" numeric(12,2) NULL DEFAULT 0,
  "project_manager_id" integer NULL,
  "tech_lead_id" integer NULL,
  "product_manager_id" integer NULL,
  "tags" text[] NULL DEFAULT '{}',
  "metadata" jsonb NULL DEFAULT '{}',
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "projects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_parent_project_id_fkey" FOREIGN KEY ("parent_project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT "projects_product_manager_id_fkey" FOREIGN KEY ("product_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_project_manager_id_fkey" FOREIGN KEY ("project_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_tech_lead_id_fkey" FOREIGN KEY ("tech_lead_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "projects_actual_dates_valid" CHECK ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end >= actual_start)),
  CONSTRAINT "projects_budget_positive" CHECK ((budget_allocated IS NULL) OR (budget_allocated >= (0)::numeric)),
  CONSTRAINT "projects_budget_spent_valid" CHECK ((budget_spent >= (0)::numeric) AND ((budget_allocated IS NULL) OR (budget_spent <= (budget_allocated * 1.1)))),
  CONSTRAINT "projects_code_format" CHECK ((code)::text ~ '^[A-Z0-9_-]{2,20}$'::text),
  CONSTRAINT "projects_planned_dates_valid" CHECK (planned_end >= planned_start)
);
-- Create index "projects_code_unique" to table: "projects"
CREATE UNIQUE INDEX "projects_code_unique" ON "public"."projects" ("code");
-- Create index "projects_dates_idx" to table: "projects"
CREATE INDEX "projects_dates_idx" ON "public"."projects" ("planned_start", "planned_end");
-- Create index "projects_managers_idx" to table: "projects"
CREATE INDEX "projects_managers_idx" ON "public"."projects" ("project_manager_id", "tech_lead_id", "product_manager_id");
-- Create index "projects_metadata_gin" to table: "projects"
CREATE INDEX "projects_metadata_gin" ON "public"."projects" USING gin ("metadata");
-- Create index "projects_parent_id_idx" to table: "projects"
CREATE INDEX "projects_parent_id_idx" ON "public"."projects" ("parent_project_id");
-- Create index "projects_status_idx" to table: "projects"
CREATE INDEX "projects_status_idx" ON "public"."projects" ("status");
-- Create index "projects_tags_gin" to table: "projects"
CREATE INDEX "projects_tags_gin" ON "public"."projects" USING gin ("tags");
-- Create index "projects_type_idx" to table: "projects"
CREATE INDEX "projects_type_idx" ON "public"."projects" ("project_type");
-- Create "tasks" table
CREATE TABLE "public"."tasks" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "parent_task_id" integer NULL,
  "task_key" character varying(50) NOT NULL,
  "title" character varying(500) NOT NULL,
  "description" text NULL,
  "task_type" "public"."task_type" NOT NULL,
  "status" "public"."task_status" NOT NULL DEFAULT 'backlog',
  "priority" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "story_points" "public"."story_points" NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL DEFAULT 0,
  "remaining_hours" numeric(6,2) NULL,
  "assignee_id" integer NULL,
  "reporter_id" integer NOT NULL,
  "sprint_id" integer NULL,
  "sprint_order" integer NULL,
  "due_date" date NULL,
  "start_date" date NULL,
  "completion_date" date NULL,
  "depends_on" integer[] NULL DEFAULT '{}',
  "blocks" integer[] NULL DEFAULT '{}',
  "labels" text[] NULL DEFAULT '{}',
  "tags" text[] NULL DEFAULT '{}',
  "component" character varying(100) NULL,
  "epic_link" integer NULL,
  "resolution" character varying(100) NULL,
  "environment" character varying(50) NULL,
  "search_vector" tsvector NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "tasks_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_epic_link_fkey" FOREIGN KEY ("epic_link") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_parent_task_id_fkey" FOREIGN KEY ("parent_task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "tasks_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "tasks_dates_logical" CHECK (((start_date IS NULL) OR (due_date IS NULL) OR (start_date <= due_date)) AND ((completion_date IS NULL) OR (start_date IS NULL) OR (completion_date >= start_date))),
  CONSTRAINT "tasks_epic_self_reference" CHECK (epic_link <> id),
  CONSTRAINT "tasks_hours_positive" CHECK (((estimated_hours IS NULL) OR (estimated_hours >= (0)::numeric)) AND (actual_hours >= (0)::numeric) AND ((remaining_hours IS NULL) OR (remaining_hours >= (0)::numeric))),
  CONSTRAINT "tasks_key_format" CHECK ((task_key)::text ~ '^[A-Z]+-[0-9]+$'::text),
  CONSTRAINT "tasks_parent_self_reference" CHECK (parent_task_id <> id)
);
-- Create index "tasks_assignee_idx" to table: "tasks"
CREATE INDEX "tasks_assignee_idx" ON "public"."tasks" ("assignee_id");
-- Create index "tasks_blocks_gin" to table: "tasks"
CREATE INDEX "tasks_blocks_gin" ON "public"."tasks" USING gin ("blocks");
-- Create index "tasks_depends_on_gin" to table: "tasks"
CREATE INDEX "tasks_depends_on_gin" ON "public"."tasks" USING gin ("depends_on");
-- Create index "tasks_due_date_idx" to table: "tasks"
CREATE INDEX "tasks_due_date_idx" ON "public"."tasks" ("due_date") WHERE (due_date IS NOT NULL);
-- Create index "tasks_key_unique" to table: "tasks"
CREATE UNIQUE INDEX "tasks_key_unique" ON "public"."tasks" ("task_key");
-- Create index "tasks_labels_gin" to table: "tasks"
CREATE INDEX "tasks_labels_gin" ON "public"."tasks" USING gin ("labels");
-- Create index "tasks_parent_task_idx" to table: "tasks"
CREATE INDEX "tasks_parent_task_idx" ON "public"."tasks" ("parent_task_id");
-- Create index "tasks_project_id_idx" to table: "tasks"
CREATE INDEX "tasks_project_id_idx" ON "public"."tasks" ("project_id");
-- Create index "tasks_search_gin" to table: "tasks"
CREATE INDEX "tasks_search_gin" ON "public"."tasks" USING gin ("search_vector");
-- Create index "tasks_sprint_idx" to table: "tasks"
CREATE INDEX "tasks_sprint_idx" ON "public"."tasks" ("sprint_id");
-- Create index "tasks_status_idx" to table: "tasks"
CREATE INDEX "tasks_status_idx" ON "public"."tasks" ("status");
-- Create index "tasks_tags_gin" to table: "tasks"
CREATE INDEX "tasks_tags_gin" ON "public"."tasks" USING gin ("tags");
-- Create "task_dependencies" table
CREATE TABLE "public"."task_dependencies" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "depends_on_task_id" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_dependencies_task_id_depends_on_task_id_key" UNIQUE ("task_id", "depends_on_task_id"),
  CONSTRAINT "task_dependencies_depends_on_task_id_fkey" FOREIGN KEY ("depends_on_task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_dependencies_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_dependencies_check" CHECK (task_id <> depends_on_task_id)
);
-- Create index "idx_task_dependencies_depends_on" to table: "task_dependencies"
CREATE INDEX "idx_task_dependencies_depends_on" ON "public"."task_dependencies" ("depends_on_task_id");
-- Create index "idx_task_dependencies_task" to table: "task_dependencies"
CREATE INDEX "idx_task_dependencies_task" ON "public"."task_dependencies" ("task_id");
-- Create "check_task_dependencies" function
CREATE FUNCTION "public"."check_task_dependencies" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    dep_status task_status;
BEGIN
    -- Check if all dependencies are completed
    FOR dep_status IN 
        SELECT t.status
        FROM task_dependencies td
        JOIN tasks t ON t.id = td.depends_on_task_id
        WHERE td.task_id = NEW.id
    LOOP
        IF dep_status != 'done' AND NEW.status IN ('in_progress', 'code_review', 'testing', 'done') THEN
            RAISE EXCEPTION 'Cannot progress task: dependencies not completed';
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$;
-- Create enum type "user_role_type"
CREATE TYPE "public"."user_role_type" AS ENUM ('pm', 'project_mgr', 'eng', 'tech_lead', 'eng_mgr');
-- Create enum type "device_status"
CREATE TYPE "public"."device_status" AS ENUM ('active', 'inactive', 'maintenance', 'offline', 'error');
-- Create enum type "resource_conflict_severity"
CREATE TYPE "public"."resource_conflict_severity" AS ENUM ('none', 'minor', 'moderate', 'severe', 'critical');
-- Create enum type "schedule_type"
CREATE TYPE "public"."schedule_type" AS ENUM ('project_master', 'sprint_schedule', 'resource_plan', 'milestone_track', 'baseline', 'what_if_scenario');
-- Create enum type "production_line_status"
CREATE TYPE "manufacturing"."production_line_status" AS ENUM ('planning', 'setup', 'running', 'maintenance', 'breakdown', 'changeover', 'shutdown');
-- Create "production_lines" table
CREATE TABLE "manufacturing"."production_lines" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "description" text NULL,
  "location" character varying(200) NULL,
  "capacity_per_hour" integer NOT NULL,
  "status" "manufacturing"."production_line_status" NOT NULL DEFAULT 'planning',
  "manager_id" integer NULL,
  "project_id" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "last_production_run" timestamptz NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "production_lines_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_lines_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_lines_capacity_per_hour_check" CHECK (capacity_per_hour > 0)
);
-- Create enum type "equipment_status"
CREATE TYPE "manufacturing"."equipment_status" AS ENUM ('available', 'running', 'idle', 'maintenance', 'breakdown', 'setup', 'offline');
-- Create "equipment" table
CREATE TABLE "manufacturing"."equipment" (
  "id" serial NOT NULL,
  "production_line_id" integer NOT NULL,
  "name" character varying(100) NOT NULL,
  "equipment_type" character varying(50) NOT NULL,
  "model" character varying(100) NULL,
  "serial_number" character varying(100) NOT NULL,
  "status" "manufacturing"."equipment_status" NOT NULL DEFAULT 'available',
  "installed_date" date NULL,
  "last_maintenance" timestamptz NULL,
  "next_maintenance" timestamptz NULL,
  "specifications" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "equipment_serial_number_key" UNIQUE ("serial_number"),
  CONSTRAINT "equipment_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "manufacturing"."production_lines" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "production_run_quality_check" function
CREATE FUNCTION "manufacturing"."production_run_quality_check" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_line_name VARCHAR;
    v_equipment_count INTEGER;
    v_available_equipment INTEGER;
BEGIN
    -- Auto-calculate quality metrics when production run completes
    IF NEW.end_time IS NOT NULL AND OLD.end_time IS NULL THEN
        -- Calculate yield percentage
        IF NEW.planned_quantity > 0 THEN
            NEW.yield_percentage := (NEW.actual_quantity::NUMERIC / NEW.planned_quantity) * 100;
        END IF;
        
        -- Auto-set quality status based on yield
        IF NEW.quality_status = 'pending' THEN
            NEW.quality_status := CASE 
                WHEN NEW.yield_percentage >= 95 THEN 'pass'
                WHEN NEW.yield_percentage >= 80 THEN 'rework'
                ELSE 'fail'
            END;
        END IF;
        
        -- Update production line last run timestamp
        UPDATE manufacturing.production_lines 
        SET last_production_run = NEW.end_time
        WHERE id = NEW.production_line_id;
    END IF;
    
    -- Validate production run constraints
    IF NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
        -- Check for equipment availability during run
        SELECT 
            COUNT(*),
            COUNT(CASE WHEN status IN ('available', 'running') THEN 1 END)
        INTO v_equipment_count, v_available_equipment
        FROM manufacturing.equipment
        WHERE production_line_id = NEW.production_line_id;
        
        IF v_available_equipment = 0 THEN
            RAISE EXCEPTION 'Cannot complete production run - no equipment available on line';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create enum type "quality_status"
CREATE TYPE "manufacturing"."quality_status" AS ENUM ('pass', 'fail', 'rework', 'pending', 'quarantine', 'released');
-- Create "production_runs" table
CREATE TABLE "manufacturing"."production_runs" (
  "id" serial NOT NULL,
  "production_line_id" integer NOT NULL,
  "project_id" integer NULL,
  "assigned_user_id" integer NULL,
  "product_code" character varying(50) NOT NULL,
  "batch_number" character varying(100) NOT NULL,
  "planned_quantity" integer NOT NULL,
  "actual_quantity" integer NULL,
  "quality_status" "manufacturing"."quality_status" NOT NULL DEFAULT 'pending',
  "start_time" timestamptz NULL,
  "end_time" timestamptz NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "yield_percentage" numeric(5,2) NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "production_runs_assigned_user_id_fkey" FOREIGN KEY ("assigned_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "manufacturing"."production_lines" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "production_runs_actual_quantity_check" CHECK (actual_quantity >= 0),
  CONSTRAINT "production_runs_planned_quantity_check" CHECK (planned_quantity > 0),
  CONSTRAINT "production_runs_time_order" CHECK ((end_time IS NULL) OR (start_time IS NULL) OR (end_time > start_time))
);
-- Create trigger "production_run_quality_trigger"
CREATE TRIGGER "production_run_quality_trigger" BEFORE UPDATE ON "manufacturing"."production_runs" FOR EACH ROW EXECUTE FUNCTION "manufacturing"."production_run_quality_check"();
-- Create enum type "report_status"
CREATE TYPE "public"."report_status" AS ENUM ('draft', 'published', 'archived');
-- Create enum type "report_type"
CREATE TYPE "public"."report_type" AS ENUM ('daily_standup', 'weekly_summary', 'sprint_review', 'milestone_report', 'executive_summary', 'risk_assessment', 'budget_report', 'team_performance', 'custom');
-- Create enum type "model_framework"
CREATE TYPE "public"."model_framework" AS ENUM ('tensorflow', 'pytorch', 'scikit_learn', 'xgboost', 'lightgbm', 'keras', 'onnx', 'custom');
-- Create enum type "work_order_status"
CREATE TYPE "manufacturing"."work_order_status" AS ENUM ('planned', 'scheduled', 'in_progress', 'on_hold', 'completed', 'cancelled', 'requires_parts');
-- Create enum type "maintenance_type"
CREATE TYPE "manufacturing"."maintenance_type" AS ENUM ('preventive', 'corrective', 'predictive', 'emergency', 'calibration', 'inspection');
-- Create "maintenance_work_orders" table
CREATE TABLE "manufacturing"."maintenance_work_orders" (
  "id" serial NOT NULL,
  "work_order_number" character varying(50) NOT NULL,
  "equipment_id" integer NOT NULL,
  "maintenance_type" "manufacturing"."maintenance_type" NOT NULL,
  "status" "manufacturing"."work_order_status" NOT NULL DEFAULT 'planned',
  "priority_level" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "title" character varying(200) NOT NULL,
  "description" text NULL,
  "assigned_technician_id" integer NULL,
  "requested_by_id" integer NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL,
  "estimated_cost" numeric(12,2) NULL DEFAULT 0,
  "actual_cost" numeric(12,2) NULL DEFAULT 0,
  "scheduled_start" timestamptz NULL,
  "scheduled_end" timestamptz NULL,
  "actual_start" timestamptz NULL,
  "actual_end" timestamptz NULL,
  "completion_notes" text NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "maintenance_work_orders_work_order_number_key" UNIQUE ("work_order_number"),
  CONSTRAINT "maintenance_work_orders_assigned_technician_id_fkey" FOREIGN KEY ("assigned_technician_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_actual_hours_check" CHECK (actual_hours >= (0)::numeric),
  CONSTRAINT "maintenance_work_orders_estimated_hours_check" CHECK (estimated_hours > (0)::numeric),
  CONSTRAINT "work_orders_time_logic" CHECK (((scheduled_end IS NULL) OR (scheduled_start IS NULL) OR (scheduled_end > scheduled_start)) AND ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end > actual_start)))
);
-- Create "manufacturing_cost_analysis" view
CREATE MATERIALIZED VIEW "manufacturing"."manufacturing_cost_analysis" (
  "month",
  "production_line_id",
  "production_line_name",
  "product_code",
  "total_output",
  "production_runs",
  "estimated_labor_cost",
  "maintenance_costs",
  "equipment_depreciation",
  "total_costs",
  "cost_per_unit",
  "avg_production_hours"
) AS WITH cost_breakdown AS (
         SELECT date_trunc('month'::text, pr.start_time) AS month,
            pl.id AS production_line_id,
            pl.name AS production_line_name,
            pr.product_code,
            sum(pr.actual_quantity) AS total_output,
            count(*) AS production_runs,
            ((count(*) * 8) * 50) AS estimated_labor_cost,
            sum(wo.actual_cost) AS maintenance_costs,
            (count(DISTINCT e.id) * 1000) AS equipment_depreciation,
            avg((EXTRACT(epoch FROM (pr.end_time - pr.start_time)) / (3600)::numeric)) AS avg_production_hours
           FROM (((manufacturing.production_runs pr
             JOIN manufacturing.production_lines pl ON ((pr.production_line_id = pl.id)))
             JOIN manufacturing.equipment e ON ((pl.id = e.production_line_id)))
             LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (date_trunc('month'::text, wo.actual_start) = date_trunc('month'::text, pr.start_time)))))
          WHERE ((pr.start_time >= (CURRENT_DATE - '2 years'::interval)) AND (pr.end_time IS NOT NULL))
          GROUP BY (date_trunc('month'::text, pr.start_time)), pl.id, pl.name, pr.product_code
        )
 SELECT month,
    production_line_id,
    production_line_name,
    product_code,
    total_output,
    production_runs,
    estimated_labor_cost,
    COALESCE(maintenance_costs, (0)::numeric) AS maintenance_costs,
    equipment_depreciation,
    (((estimated_labor_cost)::numeric + COALESCE(maintenance_costs, (0)::numeric)) + (equipment_depreciation)::numeric) AS total_costs,
    ((((estimated_labor_cost)::numeric + COALESCE(maintenance_costs, (0)::numeric)) + (equipment_depreciation)::numeric) / (NULLIF(total_output, 0))::numeric) AS cost_per_unit,
    avg_production_hours
   FROM cost_breakdown
  WHERE (month IS NOT NULL);
-- Create "maintenance_workload_analysis" view
CREATE MATERIALIZED VIEW "manufacturing"."maintenance_workload_analysis" (
  "week_start",
  "maintenance_type",
  "priority_level",
  "scheduled_work_orders",
  "estimated_hours",
  "actual_hours",
  "hours_variance_ratio",
  "completed_orders",
  "overdue_completions",
  "assigned_technicians"
) AS SELECT date_trunc('week'::text, wo.scheduled_start) AS week_start,
    wo.maintenance_type,
    wo.priority_level,
    count(*) AS scheduled_work_orders,
    sum(wo.estimated_hours) AS estimated_hours,
    sum(wo.actual_hours) AS actual_hours,
    avg((wo.actual_hours / NULLIF(wo.estimated_hours, (0)::numeric))) AS hours_variance_ratio,
    count(
        CASE
            WHEN (wo.status = 'completed'::manufacturing.work_order_status) THEN 1
            ELSE NULL::integer
        END) AS completed_orders,
    count(
        CASE
            WHEN (wo.actual_end > wo.scheduled_end) THEN 1
            ELSE NULL::integer
        END) AS overdue_completions,
    string_agg(DISTINCT (((u.first_name)::text || ' '::text) || (u.last_name)::text), ', '::text) AS assigned_technicians
   FROM (manufacturing.maintenance_work_orders wo
     LEFT JOIN public.users u ON ((wo.assigned_technician_id = u.id)))
  WHERE ((wo.scheduled_start >= (CURRENT_DATE - '84 days'::interval)) AND (wo.scheduled_start <= (CURRENT_DATE + '28 days'::interval)))
  GROUP BY (date_trunc('week'::text, wo.scheduled_start)), wo.maintenance_type, wo.priority_level;
-- Create "equipment_utilization_matrix" view
CREATE MATERIALIZED VIEW "manufacturing"."equipment_utilization_matrix" (
  "equipment_id",
  "equipment_name",
  "equipment_type",
  "production_line_name",
  "month",
  "production_hours",
  "maintenance_hours",
  "total_month_hours",
  "production_utilization_pct",
  "maintenance_utilization_pct",
  "total_utilization_pct"
) AS WITH equipment_hours AS (
         SELECT e.id AS equipment_id,
            e.name AS equipment_name,
            e.equipment_type,
            pl.name AS production_line_name,
            date_trunc('month'::text, pr.start_time) AS month,
            sum((EXTRACT(epoch FROM (pr.end_time - pr.start_time)) / (3600)::numeric)) AS production_hours,
            sum(wo.actual_hours) AS maintenance_hours,
            ((24)::numeric * EXTRACT(days FROM ((date_trunc('month'::text, pr.start_time) + '1 mon'::interval) - date_trunc('month'::text, pr.start_time)))) AS total_month_hours
           FROM (((manufacturing.equipment e
             JOIN manufacturing.production_lines pl ON ((e.production_line_id = pl.id)))
             LEFT JOIN manufacturing.production_runs pr ON (((pl.id = pr.production_line_id) AND (pr.start_time >= (CURRENT_DATE - '1 year'::interval)) AND (pr.end_time IS NOT NULL))))
             LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (wo.actual_start >= (CURRENT_DATE - '1 year'::interval)) AND (wo.actual_end IS NOT NULL))))
          GROUP BY e.id, e.name, e.equipment_type, pl.name, (date_trunc('month'::text, pr.start_time))
        )
 SELECT equipment_id,
    equipment_name,
    equipment_type,
    production_line_name,
    month,
    production_hours,
    maintenance_hours,
    total_month_hours,
    ((production_hours / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS production_utilization_pct,
    ((maintenance_hours / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS maintenance_utilization_pct,
    (((production_hours + COALESCE(maintenance_hours, (0)::numeric)) / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS total_utilization_pct
   FROM equipment_hours
  WHERE (month IS NOT NULL);
-- Create "equipment_health_dashboard" view
CREATE MATERIALIZED VIEW "manufacturing"."equipment_health_dashboard" (
  "equipment_id",
  "equipment_name",
  "equipment_type",
  "status",
  "production_line_name",
  "maintenance_status",
  "total_work_orders",
  "open_work_orders",
  "avg_maintenance_hours",
  "total_maintenance_cost",
  "days_since_maintenance"
) AS SELECT e.id AS equipment_id,
    e.name AS equipment_name,
    e.equipment_type,
    e.status,
    pl.name AS production_line_name,
        CASE
            WHEN (e.next_maintenance <= CURRENT_DATE) THEN 'overdue'::text
            WHEN (e.next_maintenance <= (CURRENT_DATE + '7 days'::interval)) THEN 'due_soon'::text
            ELSE 'ok'::text
        END AS maintenance_status,
    count(wo.id) AS total_work_orders,
    count(
        CASE
            WHEN (wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status, 'in_progress'::manufacturing.work_order_status])) THEN 1
            ELSE NULL::integer
        END) AS open_work_orders,
    avg(wo.actual_hours) AS avg_maintenance_hours,
    sum(wo.actual_cost) AS total_maintenance_cost,
    EXTRACT(days FROM ((CURRENT_DATE)::timestamp with time zone - e.last_maintenance)) AS days_since_maintenance
   FROM ((manufacturing.equipment e
     JOIN manufacturing.production_lines pl ON ((e.production_line_id = pl.id)))
     LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (wo.created_at >= (CURRENT_DATE - '6 mons'::interval)))))
  GROUP BY e.id, e.name, e.equipment_type, e.status, pl.name, e.next_maintenance, e.last_maintenance;
-- Create "daily_production_summary" view
CREATE MATERIALIZED VIEW "manufacturing"."daily_production_summary" (
  "production_date",
  "active_lines",
  "total_runs",
  "unique_products",
  "planned_output",
  "actual_output",
  "overall_yield",
  "quality_pass_count",
  "quality_fail_count",
  "rework_count",
  "avg_run_duration_hours",
  "extended_runs",
  "products_produced"
) AS SELECT date(start_time) AS production_date,
    count(DISTINCT production_line_id) AS active_lines,
    count(*) AS total_runs,
    count(DISTINCT product_code) AS unique_products,
    sum(planned_quantity) AS planned_output,
    sum(actual_quantity) AS actual_output,
    ((sum(actual_quantity) / NULLIF(sum(planned_quantity), 0)) * 100) AS overall_yield,
    count(
        CASE
            WHEN (quality_status = 'pass'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS quality_pass_count,
    count(
        CASE
            WHEN (quality_status = 'fail'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS quality_fail_count,
    count(
        CASE
            WHEN (quality_status = 'rework'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS rework_count,
    avg((EXTRACT(epoch FROM (end_time - start_time)) / (3600)::numeric)) AS avg_run_duration_hours,
    count(
        CASE
            WHEN (end_time > (start_time + '08:00:00'::interval)) THEN 1
            ELSE NULL::integer
        END) AS extended_runs,
    string_agg(DISTINCT (product_code)::text, ', '::text ORDER BY (product_code)::text) AS products_produced
   FROM manufacturing.production_runs pr
  WHERE ((start_time >= (CURRENT_DATE - '90 days'::interval)) AND (end_time IS NOT NULL))
  GROUP BY (date(start_time));
-- Create "refresh_manufacturing_analytics" function
CREATE FUNCTION "manufacturing"."refresh_manufacturing_analytics" () RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    v_start_time TIMESTAMPTZ;
    v_refresh_count INTEGER := 0;
BEGIN
    v_start_time := CURRENT_TIMESTAMP;
    
    -- Refresh materialized views in dependency order
    
    -- 1. Equipment health dashboard (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.equipment_health_dashboard;
    v_refresh_count := v_refresh_count + 1;
    
    -- 2. Maintenance workload analysis (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.maintenance_workload_analysis;
    v_refresh_count := v_refresh_count + 1;
    
    -- 3. Equipment utilization matrix (depends on production data)
    REFRESH MATERIALIZED VIEW manufacturing.equipment_utilization_matrix;
    v_refresh_count := v_refresh_count + 1;
    
    -- 4. Daily production summary (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.daily_production_summary;
    v_refresh_count := v_refresh_count + 1;
    
    -- 5. Manufacturing cost analysis (depends on multiple sources)
    REFRESH MATERIALIZED VIEW manufacturing.manufacturing_cost_analysis;
    v_refresh_count := v_refresh_count + 1;
    
    -- Log the refresh operation (could extend to create audit table)
    RAISE NOTICE 'Manufacturing analytics refresh completed. Views refreshed: %, Duration: %', 
        v_refresh_count, 
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start_time)) || ' seconds';
        
    -- Optional: Could insert into an audit/log table here
    /*
    INSERT INTO manufacturing.analytics_refresh_log (
        refresh_timestamp,
        views_refreshed,
        duration_seconds,
        status
    ) VALUES (
        v_start_time,
        v_refresh_count,
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start_time)),
        'completed'
    );
    */
END;
$$;
-- Create enum type "model_task_type"
CREATE TYPE "public"."model_task_type" AS ENUM ('classification', 'regression', 'clustering', 'recommendation', 'nlp', 'computer_vision', 'time_series', 'reinforcement_learning', 'generative');
-- Create enum type "deployment_environment"
CREATE TYPE "public"."deployment_environment" AS ENUM ('development', 'staging', 'production', 'edge');
-- Create enum type "deployment_status"
CREATE TYPE "public"."deployment_status" AS ENUM ('deploying', 'active', 'inactive', 'failed', 'rollback');
-- Create enum type "alert_severity"
CREATE TYPE "public"."alert_severity" AS ENUM ('low', 'medium', 'high', 'critical');
-- Create enum type "alert_status"
CREATE TYPE "public"."alert_status" AS ENUM ('open', 'acknowledged', 'resolved', 'escalated');
-- Create enum type "event_severity"
CREATE TYPE "public"."event_severity" AS ENUM ('info', 'warning', 'high', 'critical');
-- Create enum type "security_event_type"
CREATE TYPE "public"."security_event_type" AS ENUM ('login_attempt', 'access_denied', 'data_breach', 'malware_detected', 'policy_violation', 'system_anomaly');
-- Create enum type "threat_category"
CREATE TYPE "public"."threat_category" AS ENUM ('malware', 'phishing', 'ddos', 'data_theft', 'unauthorized_access', 'insider_threat');
-- Create enum type "incident_status"
CREATE TYPE "public"."incident_status" AS ENUM ('detected', 'investigating', 'contained', 'resolved', 'post_mortem');
-- Create enum type "doc_format"
CREATE TYPE "public"."doc_format" AS ENUM ('markdown', 'html', 'pdf', 'docx', 'txt');
-- Create enum type "doc_status"
CREATE TYPE "public"."doc_status" AS ENUM ('draft', 'review', 'approved', 'published', 'archived');
-- Create enum type "cadence_type"
CREATE TYPE "public"."cadence_type" AS ENUM ('daily', 'weekly', 'bi_weekly', 'monthly', 'quarterly', 'on_demand');
-- Create enum type "experiment_status"
CREATE TYPE "public"."experiment_status" AS ENUM ('running', 'completed', 'failed', 'cancelled', 'scheduled');
-- Create composite type "date_range"
CREATE TYPE "public"."date_range" AS ("start_date" date, "end_date" date);
-- Create "optimize_production_schedule" function
CREATE FUNCTION "manufacturing"."optimize_production_schedule" ("p_production_line_id" integer, "p_optimization_days" integer DEFAULT 7) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_schedule JSONB := '[]'::JSONB;
    v_current_date DATE := CURRENT_DATE;
    v_line_capacity INTEGER;
    v_daily_schedule JSONB;
    rec RECORD;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour * 24 -- Daily capacity
    INTO v_line_capacity
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Production line with ID % not found', p_production_line_id;
    END IF;
    
    -- Generate optimized schedule for each day
    FOR i IN 0..p_optimization_days-1 LOOP
        v_current_date := CURRENT_DATE + i;
        v_daily_schedule := '[]'::JSONB;
        
        -- Get pending production runs that could be scheduled
        -- Priority: 1) Past due, 2) High priority projects, 3) FIFO
        FOR rec IN (
            WITH pending_runs AS (
                SELECT 
                    pr.*,
                    p.priority_level as project_priority,
                    CASE 
                        WHEN pr.start_time IS NULL THEN 'unscheduled'
                        WHEN pr.start_time < CURRENT_TIMESTAMP THEN 'overdue'
                        ELSE 'scheduled'
                    END as run_status,
                    pr.planned_quantity as remaining_quantity
                FROM manufacturing.production_runs pr
                LEFT JOIN public.projects p ON pr.project_id = p.id
                WHERE pr.production_line_id = p_production_line_id
                    AND pr.end_time IS NULL -- Not completed
                    AND pr.quality_status = 'pending' -- Not yet processed
            )
            SELECT *,
                ROW_NUMBER() OVER (
                    ORDER BY 
                        CASE WHEN run_status = 'overdue' THEN 1 ELSE 2 END,
                        CASE WHEN project_priority = 'high' THEN 1 
                             WHEN project_priority = 'medium' THEN 2 
                             ELSE 3 END,
                        created_at ASC
                ) as priority_rank
            FROM pending_runs
        ) LOOP
            
            -- Check if we have capacity for this run
            IF (v_daily_schedule->'scheduled_quantity')::INTEGER + rec.remaining_quantity <= v_line_capacity THEN
                
                v_daily_schedule := jsonb_set(
                    v_daily_schedule,
                    '{runs}',
                    COALESCE(v_daily_schedule->'runs', '[]'::JSONB) || 
                    jsonb_build_object(
                        'production_run_id', rec.id,
                        'product_code', rec.product_code,
                        'batch_number', rec.batch_number,
                        'planned_quantity', rec.remaining_quantity,
                        'estimated_hours', (rec.remaining_quantity::NUMERIC / (v_line_capacity / 24)),
                        'priority_rank', rec.priority_rank,
                        'project_priority', rec.project_priority
                    )
                );
                
                -- Update scheduled quantity
                v_daily_schedule := jsonb_set(
                    v_daily_schedule,
                    '{scheduled_quantity}',
                    to_jsonb(COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0) + rec.remaining_quantity)
                );
            END IF;
        END LOOP;
        
        -- Add daily schedule metadata
        v_daily_schedule := v_daily_schedule || jsonb_build_object(
            'date', v_current_date,
            'capacity_total', v_line_capacity,
            'capacity_utilized', COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0),
            'capacity_utilization_pct', 
                ROUND((COALESCE((v_daily_schedule->'scheduled_quantity')::INTEGER, 0)::NUMERIC / v_line_capacity) * 100, 2),
            'runs_count', jsonb_array_length(COALESCE(v_daily_schedule->'runs', '[]'::JSONB))
        );
        
        -- Add to overall schedule
        v_schedule := v_schedule || v_daily_schedule;
    END LOOP;
    
    -- Return complete optimized schedule
    RETURN jsonb_build_object(
        'production_line_id', p_production_line_id,
        'optimization_period_days', p_optimization_days,
        'schedule_generated_at', CURRENT_TIMESTAMP,
        'daily_schedules', v_schedule,
        'summary', jsonb_build_object(
            'total_runs_scheduled', (
                SELECT SUM(jsonb_array_length(day->'runs'))
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'avg_daily_utilization_pct', (
                SELECT ROUND(AVG((day->>'capacity_utilization_pct')::NUMERIC), 2)
                FROM jsonb_array_elements(v_schedule) as day
            )
        )
    );
END;
$$;
-- Create "user_roles" table
CREATE TABLE "public"."user_roles" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "role" "public"."user_role_type" NOT NULL,
  "effective_from" date NOT NULL DEFAULT CURRENT_DATE,
  "effective_to" date NULL,
  "assigned_by" integer NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_roles_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "user_roles_date_order" CHECK ((effective_to IS NULL) OR (effective_to > effective_from)),
  CONSTRAINT "user_roles_effective_from_reasonable" CHECK (effective_from >= '1990-01-01'::date)
);
-- Create index "user_roles_effective_dates_idx" to table: "user_roles"
CREATE INDEX "user_roles_effective_dates_idx" ON "public"."user_roles" ("effective_from", "effective_to");
-- Create index "user_roles_user_id_idx" to table: "user_roles"
CREATE INDEX "user_roles_user_id_idx" ON "public"."user_roles" ("user_id");
-- Create "auto_assign_technician" function
CREATE FUNCTION "manufacturing"."auto_assign_technician" ("p_work_order_id" integer, "p_preferred_skills" text[] DEFAULT NULL::text[]) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_assigned_technician_id INTEGER;
    v_maintenance_type manufacturing.maintenance_type;
    v_priority_level public.priority_level;
    v_estimated_hours NUMERIC;
BEGIN
    -- Get work order details
    SELECT maintenance_type, priority_level, estimated_hours
    INTO v_maintenance_type, v_priority_level, v_estimated_hours
    FROM manufacturing.maintenance_work_orders
    WHERE id = p_work_order_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Work order with ID % not found', p_work_order_id;
    END IF;
    
    -- Find available technician with lowest current workload
    -- This is a simplified algorithm - in practice you'd consider skills, certifications, etc.
    WITH technician_workload AS (
        SELECT 
            u.id as technician_id,
            u.first_name || ' ' || u.last_name as technician_name,
            COALESCE(SUM(
                CASE WHEN wo.status IN ('planned', 'scheduled', 'in_progress') 
                THEN wo.estimated_hours ELSE 0 END
            ), 0) as current_workload_hours,
            COUNT(CASE WHEN wo.maintenance_type = v_maintenance_type THEN 1 END) as experience_count
        FROM public.users u
        LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            AND wo.created_at >= CURRENT_DATE - INTERVAL '6 months'
        WHERE u.status = 'active'
            AND EXISTS (
                SELECT 1 FROM public.user_roles ur 
                WHERE ur.user_id = u.id 
                AND ur.role_type IN ('ENG', 'Tech Lead')
            )
        GROUP BY u.id, u.first_name, u.last_name
    )
    SELECT technician_id
    INTO v_assigned_technician_id
    FROM technician_workload
    WHERE current_workload_hours <= 40 -- Max 40 hours of pending work
    ORDER BY 
        CASE WHEN v_priority_level = 'high' THEN current_workload_hours ELSE experience_count END,
        current_workload_hours ASC,
        experience_count DESC
    LIMIT 1;
    
    -- If no technician found, assign to least busy one regardless of workload
    IF v_assigned_technician_id IS NULL THEN
        WITH technician_workload AS (
            SELECT 
                u.id as technician_id,
                COALESCE(SUM(
                    CASE WHEN wo.status IN ('planned', 'scheduled', 'in_progress') 
                    THEN wo.estimated_hours ELSE 0 END
                ), 0) as current_workload_hours
            FROM public.users u
            LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            WHERE u.status = 'active'
                AND EXISTS (
                    SELECT 1 FROM public.user_roles ur 
                    WHERE ur.user_id = u.id 
                    AND ur.role_type IN ('ENG', 'Tech Lead')
                )
            GROUP BY u.id
        )
        SELECT technician_id
        INTO v_assigned_technician_id
        FROM technician_workload
        ORDER BY current_workload_hours ASC
        LIMIT 1;
    END IF;
    
    -- Update work order with assigned technician
    IF v_assigned_technician_id IS NOT NULL THEN
        UPDATE manufacturing.maintenance_work_orders
        SET 
            assigned_technician_id = v_assigned_technician_id,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_work_order_id;
    END IF;
    
    RETURN v_assigned_technician_id;
END;
$$;
-- Create "maintenance_performance_metrics" table
CREATE TABLE "manufacturing"."maintenance_performance_metrics" (
  "id" serial NOT NULL,
  "work_order_id" integer NOT NULL,
  "equipment_id" integer NOT NULL,
  "maintenance_type" "manufacturing"."maintenance_type" NOT NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL,
  "hours_variance_pct" numeric(6,2) NULL,
  "estimated_cost" numeric(12,2) NULL,
  "actual_cost" numeric(12,2) NULL,
  "cost_variance_pct" numeric(6,2) NULL,
  "completion_date" timestamptz NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "maintenance_performance_metrics_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_performance_metrics_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "manufacturing"."maintenance_work_orders" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_maintenance_metrics_date" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_date" ON "manufacturing"."maintenance_performance_metrics" ("completion_date" DESC);
-- Create index "idx_maintenance_metrics_equipment" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_equipment" ON "manufacturing"."maintenance_performance_metrics" ("equipment_id");
-- Create index "idx_maintenance_metrics_type" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_type" ON "manufacturing"."maintenance_performance_metrics" ("maintenance_type");
-- Create "maintenance_work_order_completion" function
CREATE FUNCTION "manufacturing"."maintenance_work_order_completion" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_equipment_id INTEGER;
    v_maintenance_type manufacturing.maintenance_type;
BEGIN
    -- Handle work order completion
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Update equipment last maintenance date
        UPDATE manufacturing.equipment 
        SET 
            last_maintenance = NEW.actual_end,
            -- For preventive maintenance, schedule next maintenance
            next_maintenance = CASE 
                WHEN NEW.maintenance_type = 'preventive' THEN 
                    NEW.actual_end + INTERVAL '90 days'
                ELSE next_maintenance
            END
        WHERE id = NEW.equipment_id;
        
        -- Auto-change equipment status back to available if it was in maintenance
        UPDATE manufacturing.equipment 
        SET status = 'available'
        WHERE id = NEW.equipment_id 
            AND status = 'maintenance';
            
        -- Calculate actual vs estimated variance for future planning
        IF NEW.estimated_hours > 0 AND NEW.actual_hours > 0 THEN
            INSERT INTO manufacturing.maintenance_performance_metrics (
                work_order_id,
                equipment_id,
                maintenance_type,
                estimated_hours,
                actual_hours,
                hours_variance_pct,
                completion_date
            ) VALUES (
                NEW.id,
                NEW.equipment_id,
                NEW.maintenance_type,
                NEW.estimated_hours,
                NEW.actual_hours,
                ((NEW.actual_hours - NEW.estimated_hours) / NEW.estimated_hours) * 100,
                NEW.actual_end
            );
        END IF;
    END IF;
    
    -- Auto-assign work order if technician is null and status changes to scheduled
    IF NEW.status = 'scheduled' AND NEW.assigned_technician_id IS NULL THEN
        NEW.assigned_technician_id := manufacturing.auto_assign_technician(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create "generate_shift_schedule" function
CREATE FUNCTION "manufacturing"."generate_shift_schedule" ("p_production_line_id" integer, "p_start_date" date DEFAULT CURRENT_DATE, "p_days" integer DEFAULT 7) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_shift_pattern JSONB;
    v_schedule JSONB := '[]'::JSONB;
    v_current_date DATE;
    v_day_schedule JSONB;
    v_line_capacity INTEGER;
    v_technicians JSONB;
    v_shift_count INTEGER;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour INTO v_line_capacity
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Production line with ID % not found', p_production_line_id;
    END IF;
    
    -- Define standard shift pattern (3 shifts, 8 hours each)
    v_shift_pattern := jsonb_build_object(
        'day_shift', jsonb_build_object(
            'start_time', '06:00',
            'end_time', '14:00',
            'shift_code', 'DAY',
            'capacity_factor', 1.0
        ),
        'evening_shift', jsonb_build_object(
            'start_time', '14:00',
            'end_time', '22:00',
            'shift_code', 'EVE',
            'capacity_factor', 0.9
        ),
        'night_shift', jsonb_build_object(
            'start_time', '22:00',
            'end_time', '06:00',
            'shift_code', 'NIGHT',
            'capacity_factor', 0.8
        )
    );
    
    -- Get available technicians
    WITH available_technicians AS (
        SELECT 
            u.id,
            u.first_name || ' ' || u.last_name as name,
            COUNT(wo.id) as current_workload
        FROM public.users u
        LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            AND wo.status IN ('planned', 'scheduled', 'in_progress')
        WHERE u.status = 'active'
            AND EXISTS (
                SELECT 1 FROM public.user_roles ur 
                WHERE ur.user_id = u.id 
                AND ur.role_type IN ('ENG', 'Tech Lead')
            )
        GROUP BY u.id, u.first_name, u.last_name
        ORDER BY current_workload ASC
        LIMIT 12 -- Assume 4 technicians per shift
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'technician_id', id,
            'name', name,
            'workload', current_workload
        )
    ) INTO v_technicians
    FROM available_technicians;
    
    -- Generate schedule for each day
    FOR i IN 0..p_days-1 LOOP
        v_current_date := p_start_date + i;
        v_shift_count := 0;
        
        -- Determine if it''s a weekend (reduced shifts)
        v_shift_count := CASE 
            WHEN EXTRACT(DOW FROM v_current_date) IN (0, 6) THEN 2 -- Weekend: day and evening only
            ELSE 3 -- Weekday: all three shifts
        END;
        
        v_day_schedule := jsonb_build_object(
            'date', v_current_date,
            'day_of_week', EXTRACT(DOW FROM v_current_date),
            'shifts', CASE v_shift_count
                WHEN 3 THEN jsonb_build_array(
                    v_shift_pattern->'day_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->0,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'day_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'evening_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->1,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'evening_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'night_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->2,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'night_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    )
                )
                ELSE jsonb_build_array(
                    v_shift_pattern->'day_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->0,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'day_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    ),
                    v_shift_pattern->'evening_shift' || jsonb_build_object(
                        'assigned_technicians', v_technicians->1,
                        'planned_capacity', (v_line_capacity * 8 * ((v_shift_pattern->'evening_shift'->>'capacity_factor')::NUMERIC))::INTEGER
                    )
                )
            END
        );
        
        -- Add daily capacity summary
        v_day_schedule := v_day_schedule || jsonb_build_object(
            'daily_capacity_total', (
                SELECT SUM((shift->>'planned_capacity')::INTEGER)
                FROM jsonb_array_elements(v_day_schedule->'shifts') as shift
            ),
            'shift_count', v_shift_count
        );
        
        v_schedule := v_schedule || v_day_schedule;
    END LOOP;
    
    -- Return complete schedule
    RETURN jsonb_build_object(
        'production_line_id', p_production_line_id,
        'schedule_period', jsonb_build_object(
            'start_date', p_start_date,
            'end_date', p_start_date + p_days - 1,
            'total_days', p_days
        ),
        'shift_pattern', v_shift_pattern,
        'available_technicians', v_technicians,
        'daily_schedules', v_schedule,
        'schedule_generated_at', CURRENT_TIMESTAMP,
        'summary', jsonb_build_object(
            'total_shifts_scheduled', (
                SELECT SUM((day->>'shift_count')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'total_capacity_planned', (
                SELECT SUM((day->>'daily_capacity_total')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            ),
            'avg_daily_capacity', (
                SELECT AVG((day->>'daily_capacity_total')::INTEGER)
                FROM jsonb_array_elements(v_schedule) as day
            )
        )
    );
END;
$$;
-- Create "generate_production_forecast" function
CREATE FUNCTION "manufacturing"."generate_production_forecast" ("p_production_line_id" integer, "p_product_code" character varying, "p_forecast_days" integer DEFAULT 30) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_historical_avg NUMERIC;
    v_trend_factor NUMERIC;
    v_seasonal_factor NUMERIC;
    v_capacity_limit INTEGER;
    v_forecast_quantity INTEGER;
    v_confidence_level NUMERIC(3,2);
    v_result JSONB;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour * 24 -- Daily capacity assuming 24-hour operation
    INTO v_capacity_limit
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    -- Calculate historical average daily production for the product
    SELECT COALESCE(AVG(daily_production), 0)
    INTO v_historical_avg
    FROM (
        SELECT 
            DATE(start_time) as production_date,
            SUM(actual_quantity) as daily_production
        FROM manufacturing.production_runs
        WHERE production_line_id = p_production_line_id
            AND product_code = p_product_code
            AND start_time >= CURRENT_DATE - INTERVAL '90 days'
            AND end_time IS NOT NULL
        GROUP BY DATE(start_time)
    ) daily_stats;
    
    -- Calculate trend factor (simplified linear trend)
    SELECT COALESCE(
        (SELECT 
            CASE 
                WHEN COUNT(*) >= 14 THEN
                    (AVG(CASE WHEN production_date >= CURRENT_DATE - INTERVAL '14 days' THEN daily_production END) /
                     NULLIF(AVG(CASE WHEN production_date < CURRENT_DATE - INTERVAL '14 days' THEN daily_production END), 0))
                ELSE 1.0
            END
        FROM (
            SELECT 
                DATE(start_time) as production_date,
                SUM(actual_quantity) as daily_production
            FROM manufacturing.production_runs
            WHERE production_line_id = p_production_line_id
                AND product_code = p_product_code
                AND start_time >= CURRENT_DATE - INTERVAL '28 days'
                AND end_time IS NOT NULL
            GROUP BY DATE(start_time)
        ) trend_data), 1.0
    ) INTO v_trend_factor;
    
    -- Simplified seasonal factor (could be enhanced with more sophisticated analysis)
    v_seasonal_factor := 1.0 + (EXTRACT(DOW FROM CURRENT_DATE) - 3.5) * 0.02; -- Slight weekday variation
    
    -- Calculate forecast
    v_forecast_quantity := LEAST(
        (v_historical_avg * v_trend_factor * v_seasonal_factor * p_forecast_days)::INTEGER,
        v_capacity_limit * p_forecast_days
    );
    
    -- Calculate confidence level based on historical data availability and variance
    SELECT CASE 
        WHEN COUNT(*) >= 30 THEN 
            GREATEST(0.60, 1.0 - (STDDEV(daily_production) / NULLIF(AVG(daily_production), 0)))
        WHEN COUNT(*) >= 14 THEN 0.70
        WHEN COUNT(*) >= 7 THEN 0.60
        ELSE 0.50
    END
    INTO v_confidence_level
    FROM (
        SELECT 
            DATE(start_time) as production_date,
            SUM(actual_quantity) as daily_production
        FROM manufacturing.production_runs
        WHERE production_line_id = p_production_line_id
            AND product_code = p_product_code
            AND start_time >= CURRENT_DATE - INTERVAL '90 days'
            AND end_time IS NOT NULL
        GROUP BY DATE(start_time)
    ) variance_calc;
    
    -- Build result
    v_result := jsonb_build_object(
        'production_line_id', p_production_line_id,
        'product_code', p_product_code,
        'forecast_period_days', p_forecast_days,
        'historical_daily_avg', ROUND(v_historical_avg, 2),
        'trend_factor', ROUND(v_trend_factor, 3),
        'seasonal_factor', ROUND(v_seasonal_factor, 3),
        'forecasted_quantity', v_forecast_quantity,
        'capacity_limit_total', v_capacity_limit * p_forecast_days,
        'capacity_utilization_pct', ROUND((v_forecast_quantity::NUMERIC / NULLIF(v_capacity_limit * p_forecast_days, 0)) * 100, 2),
        'confidence_level', v_confidence_level,
        'forecast_generated_at', CURRENT_TIMESTAMP
    );
    
    RETURN v_result;
END;
$$;
-- Create "update_equipment_status" function
CREATE FUNCTION "manufacturing"."update_equipment_status" ("p_equipment_id" integer, "p_new_status" "manufacturing"."equipment_status", "p_reason" text DEFAULT NULL::text, "p_updated_by_user_id" integer DEFAULT NULL::integer) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    v_current_status manufacturing.equipment_status;
    v_equipment_name VARCHAR;
    v_production_line_id INTEGER;
    v_auto_work_order_id INTEGER;
BEGIN
    -- Get current equipment details
    SELECT status, name, production_line_id
    INTO v_current_status, v_equipment_name, v_production_line_id
    FROM manufacturing.equipment
    WHERE id = p_equipment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Equipment with ID % not found', p_equipment_id;
    END IF;
    
    -- Don't update if status is the same
    IF v_current_status = p_new_status THEN
        RETURN FALSE;
    END IF;
    
    -- Update equipment status
    UPDATE manufacturing.equipment
    SET 
        status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_equipment_id;
    
    -- Auto-create work order for breakdown status
    IF p_new_status = 'breakdown' THEN
        INSERT INTO manufacturing.maintenance_work_orders (
            work_order_number,
            equipment_id,
            maintenance_type,
            status,
            priority_level,
            title,
            description,
            estimated_hours,
            requested_by_id
        ) VALUES (
            'BREAKDOWN-' || p_equipment_id || '-' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT,
            p_equipment_id,
            'corrective',
            'planned',
            'high',
            'Equipment Breakdown - ' || v_equipment_name,
            'Auto-generated work order for equipment breakdown. Reason: ' || COALESCE(p_reason, 'Not specified'),
            4.0, -- Default 4 hours for breakdown
            p_updated_by_user_id
        ) RETURNING id INTO v_auto_work_order_id;
        
        -- Try to auto-assign a technician for high priority breakdown
        PERFORM manufacturing.auto_assign_technician(v_auto_work_order_id);
    END IF;
    
    -- Update production line status if all equipment is down
    IF p_new_status IN ('breakdown', 'maintenance', 'offline') THEN
        -- Check if all equipment on the line is unavailable
        IF NOT EXISTS (
            SELECT 1 FROM manufacturing.equipment 
            WHERE production_line_id = v_production_line_id 
                AND status IN ('available', 'running', 'idle')
        ) THEN
            UPDATE manufacturing.production_lines
            SET 
                status = 'maintenance',
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_production_line_id;
        END IF;
    END IF;
    
    -- If equipment comes back online, potentially update production line status
    IF p_new_status IN ('available', 'running', 'idle') AND v_current_status IN ('breakdown', 'maintenance', 'offline') THEN
        -- Check if production line can be brought back to running
        IF EXISTS (
            SELECT 1 FROM manufacturing.production_lines pl
            WHERE pl.id = v_production_line_id 
                AND pl.status = 'maintenance'
                AND NOT EXISTS (
                    SELECT 1 FROM manufacturing.equipment e
                    WHERE e.production_line_id = v_production_line_id
                        AND e.status IN ('breakdown', 'offline')
                )
        ) THEN
            UPDATE manufacturing.production_lines
            SET 
                status = 'setup', -- Ready for production but needs setup
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_production_line_id;
        END IF;
    END IF;
    
    RETURN TRUE;
END;
$$;
-- Create "equipment_status_log" table
CREATE TABLE "manufacturing"."equipment_status_log" (
  "id" serial NOT NULL,
  "equipment_id" integer NOT NULL,
  "old_status" "manufacturing"."equipment_status" NULL,
  "new_status" "manufacturing"."equipment_status" NOT NULL,
  "change_timestamp" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "change_reason" text NULL,
  "changed_by_user_id" integer NULL,
  "metadata" jsonb NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "equipment_status_log_changed_by_user_id_fkey" FOREIGN KEY ("changed_by_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "equipment_status_log_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_equipment_status_log_equipment" to table: "equipment_status_log"
CREATE INDEX "idx_equipment_status_log_equipment" ON "manufacturing"."equipment_status_log" ("equipment_id");
-- Create index "idx_equipment_status_log_timestamp" to table: "equipment_status_log"
CREATE INDEX "idx_equipment_status_log_timestamp" ON "manufacturing"."equipment_status_log" ("change_timestamp" DESC);
-- Create "equipment_status_change_notification" function
CREATE FUNCTION "manufacturing"."equipment_status_change_notification" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Auto-update equipment status based on changes
    IF NEW.status != OLD.status THEN
        -- Call the equipment status update function to handle cascading logic
        PERFORM manufacturing.update_equipment_status(NEW.id, NEW.status, 'Automated status change', NULL);
        
        -- Log significant status changes
        IF NEW.status IN ('breakdown', 'offline') OR OLD.status IN ('breakdown', 'offline') THEN
            INSERT INTO manufacturing.equipment_status_log (
                equipment_id,
                old_status,
                new_status,
                change_timestamp,
                change_reason
            ) VALUES (
                NEW.id,
                OLD.status,
                NEW.status,
                CURRENT_TIMESTAMP,
                'Automated trigger'
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create "calculate_production_efficiency" function
CREATE FUNCTION "manufacturing"."calculate_production_efficiency" ("p_production_line_id" integer, "p_start_date" date DEFAULT (CURRENT_DATE - '30 days'::interval), "p_end_date" date DEFAULT CURRENT_DATE) RETURNS numeric LANGUAGE plpgsql AS $$
DECLARE
    v_total_planned NUMERIC;
    v_total_actual NUMERIC;
    v_efficiency NUMERIC(5,2);
BEGIN
    SELECT 
        COALESCE(SUM(planned_quantity), 0),
        COALESCE(SUM(actual_quantity), 0)
    INTO v_total_planned, v_total_actual
    FROM manufacturing.production_runs pr
    WHERE pr.production_line_id = p_production_line_id
        AND DATE(pr.start_time) BETWEEN p_start_date AND p_end_date
        AND pr.end_time IS NOT NULL;
    
    IF v_total_planned = 0 THEN
        RETURN 0;
    END IF;
    
    v_efficiency := (v_total_actual / v_total_planned) * 100;
    
    RETURN LEAST(v_efficiency, 100.00);
END;
$$;
-- Create "calculate_oee" function
CREATE FUNCTION "manufacturing"."calculate_oee" ("p_production_line_id" integer, "p_calculation_date" date DEFAULT CURRENT_DATE) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_planned_hours NUMERIC := 24; -- Assume 24-hour operation
    v_actual_production_hours NUMERIC;
    v_total_pieces_produced INTEGER;
    v_total_planned_pieces INTEGER;
    v_total_quality_pieces INTEGER;
    v_availability NUMERIC(5,2);
    v_performance NUMERIC(5,2);
    v_quality NUMERIC(5,2);
    v_oee NUMERIC(5,2);
    v_result JSONB;
BEGIN
    -- Get production data for the date
    SELECT 
        COALESCE(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600), 0),
        COALESCE(SUM(actual_quantity), 0),
        COALESCE(SUM(planned_quantity), 0),
        COALESCE(SUM(CASE WHEN quality_status = 'pass' THEN actual_quantity ELSE 0 END), 0)
    INTO 
        v_actual_production_hours,
        v_total_pieces_produced,
        v_total_planned_pieces,
        v_total_quality_pieces
    FROM manufacturing.production_runs pr
    WHERE pr.production_line_id = p_production_line_id
        AND DATE(pr.start_time) = p_calculation_date
        AND pr.end_time IS NOT NULL;
    
    -- Calculate Availability (actual production time / planned production time)
    v_availability := CASE 
        WHEN v_planned_hours > 0 THEN 
            LEAST((v_actual_production_hours / v_planned_hours) * 100, 100)
        ELSE 0 
    END;
    
    -- Calculate Performance (actual production / planned production)
    v_performance := CASE 
        WHEN v_total_planned_pieces > 0 THEN 
            LEAST((v_total_pieces_produced::NUMERIC / v_total_planned_pieces) * 100, 100)
        ELSE 0 
    END;
    
    -- Calculate Quality (quality pieces / total pieces)
    v_quality := CASE 
        WHEN v_total_pieces_produced > 0 THEN 
            (v_total_quality_pieces::NUMERIC / v_total_pieces_produced) * 100
        ELSE 0 
    END;
    
    -- Calculate Overall Equipment Effectiveness (OEE)
    v_oee := (v_availability * v_performance * v_quality) / 10000;
    
    -- Build result JSON
    v_result := jsonb_build_object(
        'calculation_date', p_calculation_date,
        'production_line_id', p_production_line_id,
        'planned_hours', v_planned_hours,
        'actual_production_hours', v_actual_production_hours,
        'total_pieces_produced', v_total_pieces_produced,
        'total_planned_pieces', v_total_planned_pieces,
        'total_quality_pieces', v_total_quality_pieces,
        'availability_pct', v_availability,
        'performance_pct', v_performance,
        'quality_pct', v_quality,
        'oee_pct', v_oee,
        'oee_class', CASE 
            WHEN v_oee >= 85 THEN 'world_class'
            WHEN v_oee >= 60 THEN 'acceptable'
            WHEN v_oee >= 40 THEN 'needs_improvement'
            ELSE 'poor'
        END
    );
    
    RETURN v_result;
END;
$$;
-- Create "iot_device_models" table
CREATE TABLE "public"."iot_device_models" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "manufacturer" character varying(100) NOT NULL,
  "model_number" character varying(50) NOT NULL,
  "firmware_version" character varying(20) NULL,
  "supported_sensors" "public"."sensor_type"[] NOT NULL,
  "specifications" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_device_models_manufacturer_model_number_key" UNIQUE ("manufacturer", "model_number")
);
-- Create "iot_devices" table
CREATE TABLE "public"."iot_devices" (
  "id" serial NOT NULL,
  "device_model_id" integer NOT NULL,
  "serial_number" character varying(100) NOT NULL,
  "location" character varying(200) NULL,
  "coordinates" point NULL,
  "status" "public"."device_status" NOT NULL DEFAULT 'active',
  "deployed_at" timestamptz NULL,
  "last_seen" timestamptz NULL,
  "first_seen" timestamptz NOT NULL,
  "metadata" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_devices_serial_number_key" UNIQUE ("serial_number"),
  CONSTRAINT "iot_devices_device_model_id_fkey" FOREIGN KEY ("device_model_id") REFERENCES "public"."iot_device_models" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_iot_devices_last_seen" to table: "iot_devices"
CREATE INDEX "idx_iot_devices_last_seen" ON "public"."iot_devices" ("last_seen");
-- Create index "idx_iot_devices_status" to table: "iot_devices"
CREATE INDEX "idx_iot_devices_status" ON "public"."iot_devices" ("status");
-- Create "update_device_last_seen" function
CREATE FUNCTION "public"."update_device_last_seen" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE iot_devices 
    SET last_seen = NEW.timestamp 
    WHERE id = NEW.device_id;
    RETURN NEW;
END;
$$;
-- Create "iot_sensor_data" table
CREATE TABLE "public"."iot_sensor_data" (
  "device_id" integer NOT NULL,
  "sensor_type" "public"."sensor_type" NOT NULL,
  "value" numeric NOT NULL,
  "unit" character varying(20) NOT NULL,
  "timestamp" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "quality_score" numeric(3,2) NULL,
  "metadata" jsonb NULL,
  PRIMARY KEY ("device_id", "sensor_type", "timestamp"),
  CONSTRAINT "iot_sensor_data_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "public"."iot_devices" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "iot_sensor_data_quality_score_check" CHECK ((quality_score >= (0)::numeric) AND (quality_score <= (1)::numeric))
) PARTITION BY RANGE ("timestamp");
-- Create index "idx_iot_sensor_data_device_time" to table: "iot_sensor_data"
CREATE INDEX "idx_iot_sensor_data_device_time" ON "public"."iot_sensor_data" ("device_id", "timestamp" DESC);
-- Create trigger "trg_update_device_last_seen"
CREATE TRIGGER "trg_update_device_last_seen" AFTER INSERT ON "public"."iot_sensor_data" FOR EACH ROW EXECUTE FUNCTION "public"."update_device_last_seen"();
-- Create "update_knowledge_search_vector" function
CREATE FUNCTION "public"."update_knowledge_search_vector" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.summary, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'B');
    RETURN NEW;
END;
$$;
-- Create "knowledge_categories" table
CREATE TABLE "public"."knowledge_categories" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "slug" character varying(100) NOT NULL,
  "parent_id" integer NULL,
  "description" text NULL,
  "icon" character varying(50) NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_categories_slug_key" UNIQUE ("slug"),
  CONSTRAINT "knowledge_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."knowledge_categories" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "knowledge_documents" table
CREATE TABLE "public"."knowledge_documents" (
  "id" serial NOT NULL,
  "title" character varying(200) NOT NULL,
  "slug" character varying(200) NOT NULL,
  "category_id" integer NULL,
  "format" "public"."doc_format" NOT NULL DEFAULT 'markdown',
  "status" "public"."doc_status" NOT NULL DEFAULT 'draft',
  "author_id" integer NOT NULL,
  "content" text NOT NULL,
  "summary" text NULL,
  "tags" text[] NULL DEFAULT '{}',
  "search_vector" tsvector NULL,
  "view_count" integer NULL DEFAULT 0,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "published_at" timestamptz NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_documents_slug_key" UNIQUE ("slug"),
  CONSTRAINT "knowledge_documents_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "knowledge_documents_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."knowledge_categories" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_knowledge_documents_author" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_author" ON "public"."knowledge_documents" ("author_id");
-- Create index "idx_knowledge_documents_category" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_category" ON "public"."knowledge_documents" ("category_id");
-- Create index "idx_knowledge_documents_search" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_search" ON "public"."knowledge_documents" USING gin ("search_vector");
-- Create index "idx_knowledge_documents_status" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_status" ON "public"."knowledge_documents" ("status");
-- Create index "idx_knowledge_documents_tags" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_tags" ON "public"."knowledge_documents" USING gin ("tags");
-- Create trigger "trg_update_knowledge_search_vector"
CREATE TRIGGER "trg_update_knowledge_search_vector" BEFORE INSERT OR UPDATE OF "title", "content", "summary", "tags" ON "public"."knowledge_documents" FOR EACH ROW EXECUTE FUNCTION "public"."update_knowledge_search_vector"();
-- Create "knowledge_document_versions" table
CREATE TABLE "public"."knowledge_document_versions" (
  "id" serial NOT NULL,
  "document_id" integer NOT NULL,
  "version_number" integer NOT NULL,
  "content" text NOT NULL,
  "change_summary" text NULL,
  "author_id" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_document_versions_document_id_version_number_key" UNIQUE ("document_id", "version_number"),
  CONSTRAINT "knowledge_document_versions_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "knowledge_document_versions_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."knowledge_documents" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "create_document_version" function
CREATE FUNCTION "public"."create_document_version" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_version_number INTEGER;
BEGIN
    IF OLD.content != NEW.content THEN
        SELECT COALESCE(MAX(version_number), 0) + 1 INTO v_version_number
        FROM knowledge_document_versions
        WHERE document_id = NEW.id;
        
        INSERT INTO knowledge_document_versions (
            document_id,
            version_number,
            content,
            author_id
        ) VALUES (
            NEW.id,
            v_version_number,
            OLD.content,
            NEW.author_id
        );
    END IF;
    RETURN NEW;
END;
$$;
-- Create trigger "trg_create_document_version"
CREATE TRIGGER "trg_create_document_version" BEFORE UPDATE ON "public"."knowledge_documents" FOR EACH ROW WHEN (old.content IS DISTINCT FROM new.content) EXECUTE FUNCTION "public"."create_document_version"();
-- Create "update_updated_at" function
CREATE FUNCTION "public"."update_updated_at" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
-- Create "ml_datasets" table
CREATE TABLE "public"."ml_datasets" (
  "id" serial NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "dataset_type" character varying(50) NOT NULL,
  "source_uri" text NOT NULL,
  "format" character varying(50) NOT NULL,
  "size_gb" numeric(10,3) NULL,
  "row_count" bigint NULL,
  "column_count" integer NULL,
  "schema_definition" jsonb NULL,
  "statistics" jsonb NULL,
  "quality_metrics" jsonb NULL,
  "tags" text[] NULL DEFAULT '{}',
  "is_active" boolean NOT NULL DEFAULT true,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "ml_datasets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_datasets_counts_positive" CHECK (((row_count IS NULL) OR (row_count > 0)) AND ((column_count IS NULL) OR (column_count > 0))),
  CONSTRAINT "ml_datasets_size_positive" CHECK ((size_gb IS NULL) OR (size_gb > (0)::numeric))
);
-- Create index "ml_datasets_active_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_active_idx" ON "public"."ml_datasets" ("is_active");
-- Create index "ml_datasets_name_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_name_idx" ON "public"."ml_datasets" ("name");
-- Create index "ml_datasets_tags_gin" to table: "ml_datasets"
CREATE INDEX "ml_datasets_tags_gin" ON "public"."ml_datasets" USING gin ("tags");
-- Create index "ml_datasets_type_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_type_idx" ON "public"."ml_datasets" ("dataset_type");
-- Create trigger "ml_datasets_updated_at_trigger"
CREATE TRIGGER "ml_datasets_updated_at_trigger" BEFORE UPDATE ON "public"."ml_datasets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create enum type "model_status"
CREATE TYPE "public"."model_status" AS ENUM ('development', 'staging', 'production', 'deprecated', 'archived');
-- Create "ml_models" table
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
-- Create index "ml_models_framework_idx" to table: "ml_models"
CREATE INDEX "ml_models_framework_idx" ON "public"."ml_models" ("framework");
-- Create index "ml_models_metrics_gin" to table: "ml_models"
CREATE INDEX "ml_models_metrics_gin" ON "public"."ml_models" USING gin ("validation_metrics");
-- Create index "ml_models_name_version_unique" to table: "ml_models"
CREATE UNIQUE INDEX "ml_models_name_version_unique" ON "public"."ml_models" ("name", "version");
-- Create index "ml_models_status_idx" to table: "ml_models"
CREATE INDEX "ml_models_status_idx" ON "public"."ml_models" ("status");
-- Create index "ml_models_task_type_idx" to table: "ml_models"
CREATE INDEX "ml_models_task_type_idx" ON "public"."ml_models" ("task_type");
-- Create "ml_experiments" table
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
-- Create index "ml_experiments_dates_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_dates_idx" ON "public"."ml_experiments" ("start_time", "end_time");
-- Create index "ml_experiments_framework_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_framework_idx" ON "public"."ml_experiments" ("framework");
-- Create index "ml_experiments_key_unique" to table: "ml_experiments"
CREATE UNIQUE INDEX "ml_experiments_key_unique" ON "public"."ml_experiments" ("experiment_key");
-- Create index "ml_experiments_metrics_gin" to table: "ml_experiments"
CREATE INDEX "ml_experiments_metrics_gin" ON "public"."ml_experiments" USING gin ("metrics");
-- Create index "ml_experiments_model_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_model_idx" ON "public"."ml_experiments" ("model_id");
-- Create index "ml_experiments_status_idx" to table: "ml_experiments"
CREATE INDEX "ml_experiments_status_idx" ON "public"."ml_experiments" ("status");
-- Create index "ml_experiments_tags_gin" to table: "ml_experiments"
CREATE INDEX "ml_experiments_tags_gin" ON "public"."ml_experiments" USING gin ("tags");
-- Create trigger "ml_experiments_updated_at_trigger"
CREATE TRIGGER "ml_experiments_updated_at_trigger" BEFORE UPDATE ON "public"."ml_experiments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "ml_model_deployments" table
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
-- Create index "ml_deployments_active_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_active_idx" ON "public"."ml_model_deployments" ("status", "environment") WHERE (status = 'active'::public.deployment_status);
-- Create index "ml_deployments_environment_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_environment_idx" ON "public"."ml_model_deployments" ("environment");
-- Create index "ml_deployments_model_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_model_idx" ON "public"."ml_model_deployments" ("model_id");
-- Create index "ml_deployments_name_env_unique" to table: "ml_model_deployments"
CREATE UNIQUE INDEX "ml_deployments_name_env_unique" ON "public"."ml_model_deployments" ("deployment_name", "environment");
-- Create index "ml_deployments_status_idx" to table: "ml_model_deployments"
CREATE INDEX "ml_deployments_status_idx" ON "public"."ml_model_deployments" ("status");
-- Create trigger "ml_model_deployments_updated_at_trigger"
CREATE TRIGGER "ml_model_deployments_updated_at_trigger" BEFORE UPDATE ON "public"."ml_model_deployments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create trigger "ml_models_updated_at_trigger"
CREATE TRIGGER "ml_models_updated_at_trigger" BEFORE UPDATE ON "public"."ml_models" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "project_milestones" table
CREATE TABLE "public"."project_milestones" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "planned_date" date NOT NULL,
  "actual_date" date NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "milestone_type" character varying(50) NOT NULL DEFAULT 'delivery',
  "dependencies" integer[] NULL DEFAULT '{}',
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_milestones_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "project_milestones_date_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_date_idx" ON "public"."project_milestones" ("planned_date");
-- Create index "project_milestones_project_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_project_idx" ON "public"."project_milestones" ("project_id");
-- Create index "project_milestones_status_idx" to table: "project_milestones"
CREATE INDEX "project_milestones_status_idx" ON "public"."project_milestones" ("status");
-- Create trigger "project_milestones_updated_at_trigger"
CREATE TRIGGER "project_milestones_updated_at_trigger" BEFORE UPDATE ON "public"."project_milestones" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "project_phases" table
CREATE TABLE "public"."project_phases" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "phase_name" character varying(100) NOT NULL,
  "description" text NULL,
  "planned_start" date NOT NULL,
  "planned_end" date NOT NULL,
  "actual_start" date NULL,
  "actual_end" date NULL,
  "status" "public"."project_status_type" NOT NULL DEFAULT 'planning',
  "deliverables" text[] NULL,
  "success_criteria" text[] NULL,
  "phase_order" integer NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_phases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_phases_actual_dates_valid" CHECK ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end >= actual_start)),
  CONSTRAINT "project_phases_dates_valid" CHECK (planned_end >= planned_start),
  CONSTRAINT "project_phases_order_positive" CHECK (phase_order > 0)
);
-- Create index "project_phases_project_idx" to table: "project_phases"
CREATE INDEX "project_phases_project_idx" ON "public"."project_phases" ("project_id");
-- Create index "project_phases_status_idx" to table: "project_phases"
CREATE INDEX "project_phases_status_idx" ON "public"."project_phases" ("status");
-- Create "update_project_status_from_phases" function
CREATE FUNCTION "public"."update_project_status_from_phases" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    active_phases integer;
    completed_phases integer;
    total_phases integer;
BEGIN
    SELECT 
        COUNT(*) FILTER (WHERE status = 'active'),
        COUNT(*) FILTER (WHERE status = 'completed'),
        COUNT(*)
    INTO active_phases, completed_phases, total_phases
    FROM project_phases
    WHERE project_id = NEW.project_id;
    
    -- Update project status based on phase statuses
    IF completed_phases = total_phases AND total_phases > 0 THEN
        UPDATE projects SET status = 'completed' WHERE id = NEW.project_id;
    ELSIF active_phases > 0 THEN
        UPDATE projects SET status = 'active' WHERE id = NEW.project_id;
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create trigger "project_status_from_phases_trigger"
CREATE TRIGGER "project_status_from_phases_trigger" AFTER DELETE OR INSERT OR UPDATE ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_project_status_from_phases"();
-- Create trigger "trg_update_project_status_from_phases"
CREATE TRIGGER "trg_update_project_status_from_phases" AFTER UPDATE OF "status" ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_project_status_from_phases"();
-- Create trigger "project_phases_updated_at_trigger"
CREATE TRIGGER "project_phases_updated_at_trigger" BEFORE UPDATE ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "calculate_maintenance_forecast" function
CREATE FUNCTION "manufacturing"."calculate_maintenance_forecast" ("p_equipment_id" integer DEFAULT NULL::integer, "p_forecast_months" integer DEFAULT 6) RETURNS TABLE ("equipment_id" integer, "equipment_name" character varying, "maintenance_type" "manufacturing"."maintenance_type", "predicted_date" date, "confidence_level" numeric, "estimated_cost" numeric, "priority_level" "public"."priority_level") LANGUAGE plpgsql AS $$
DECLARE
    v_equipment_filter TEXT := '';
BEGIN
    -- Build equipment filter
    IF p_equipment_id IS NOT NULL THEN
        v_equipment_filter := ' AND e.id = ' || p_equipment_id;
    END IF;
    
    RETURN QUERY EXECUTE format('
        WITH equipment_maintenance_patterns AS (
            SELECT 
                e.id as equipment_id,
                e.name as equipment_name,
                e.last_maintenance,
                e.next_maintenance,
                -- Calculate average time between maintenance based on history
                COALESCE(
                    AVG(EXTRACT(DAYS FROM (wo.actual_end - LAG(wo.actual_end) OVER (
                        PARTITION BY e.id, wo.maintenance_type 
                        ORDER BY wo.actual_end
                    )))), 90
                ) as avg_days_between_maintenance,
                wo.maintenance_type,
                AVG(wo.actual_cost) as avg_cost,
                COUNT(*) as historical_count
            FROM manufacturing.equipment e
            LEFT JOIN manufacturing.maintenance_work_orders wo ON e.id = wo.equipment_id
                AND wo.status = ''completed''
                AND wo.actual_end >= CURRENT_DATE - INTERVAL ''2 years''
            WHERE 1=1 %s
            GROUP BY e.id, e.name, e.last_maintenance, e.next_maintenance, wo.maintenance_type
        ),
        forecasted_maintenance AS (
            SELECT 
                emp.equipment_id,
                emp.equipment_name,
                emp.maintenance_type,
                -- Predict next maintenance date
                CASE 
                    WHEN emp.maintenance_type = ''preventive'' THEN
                        COALESCE(emp.next_maintenance::DATE, 
                                CURRENT_DATE + (emp.avg_days_between_maintenance || '' days'')::INTERVAL)
                    WHEN emp.maintenance_type = ''corrective'' THEN
                        -- Predict based on equipment age and failure patterns
                        CURRENT_DATE + (emp.avg_days_between_maintenance * 0.8 || '' days'')::INTERVAL
                    ELSE
                        CURRENT_DATE + (emp.avg_days_between_maintenance || '' days'')::INTERVAL
                END::DATE as predicted_date,
                -- Calculate confidence based on historical data availability
                CASE 
                    WHEN emp.historical_count >= 5 THEN 0.85
                    WHEN emp.historical_count >= 3 THEN 0.70
                    WHEN emp.historical_count >= 1 THEN 0.55
                    ELSE 0.40
                END as confidence_level,
                COALESCE(emp.avg_cost, 
                    CASE emp.maintenance_type
                        WHEN ''preventive'' THEN 500.00
                        WHEN ''corrective'' THEN 1500.00
                        WHEN ''predictive'' THEN 300.00
                        WHEN ''emergency'' THEN 2500.00
                        ELSE 800.00
                    END
                ) as estimated_cost,
                CASE emp.maintenance_type
                    WHEN ''emergency'' THEN ''high''::public.priority_level
                    WHEN ''corrective'' THEN ''high''::public.priority_level  
                    WHEN ''preventive'' THEN ''medium''::public.priority_level
                    ELSE ''low''::public.priority_level
                END as priority_level
            FROM equipment_maintenance_patterns emp
            WHERE emp.maintenance_type IS NOT NULL
        )
        SELECT 
            fm.equipment_id,
            fm.equipment_name,
            fm.maintenance_type,
            fm.predicted_date,
            fm.confidence_level,
            fm.estimated_cost,
            fm.priority_level
        FROM forecasted_maintenance fm
        WHERE fm.predicted_date <= CURRENT_DATE + INTERVAL ''%s months''
        ORDER BY fm.predicted_date ASC, fm.priority_level DESC, fm.equipment_id
    ', v_equipment_filter, p_forecast_months);
END;
$$;
-- Create "validate_project_timeline" function
CREATE FUNCTION "public"."validate_project_timeline" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Ensure planned dates are valid
    IF NEW.planned_end < NEW.planned_start THEN
        RAISE EXCEPTION 'Planned end date must be after planned start date';
    END IF;
    
    -- Ensure actual dates are valid if provided
    IF NEW.actual_start IS NOT NULL AND NEW.actual_end IS NOT NULL THEN
        IF NEW.actual_end < NEW.actual_start THEN
            RAISE EXCEPTION 'Actual end date must be after actual start date';
        END IF;
    END IF;
    
    -- Check parent project dates if applicable
    IF NEW.parent_project_id IS NOT NULL THEN
        DECLARE
            parent_start date;
            parent_end date;
        BEGIN
            SELECT planned_start, planned_end INTO parent_start, parent_end
            FROM projects WHERE id = NEW.parent_project_id;
            
            IF NEW.planned_start < parent_start OR NEW.planned_end > parent_end THEN
                RAISE EXCEPTION 'Sub-project dates must be within parent project timeline';
            END IF;
        END;
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create trigger "projects_timeline_validation_trigger"
CREATE TRIGGER "projects_timeline_validation_trigger" BEFORE INSERT OR UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."validate_project_timeline"();
-- Create trigger "trg_validate_project_timeline"
CREATE TRIGGER "trg_validate_project_timeline" BEFORE INSERT OR UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."validate_project_timeline"();
-- Create trigger "projects_updated_at_trigger"
CREATE TRIGGER "projects_updated_at_trigger" BEFORE UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "report_metrics_snapshots" table
CREATE TABLE "public"."report_metrics_snapshots" (
  "id" serial NOT NULL,
  "metric_name" character varying(100) NOT NULL,
  "metric_value" jsonb NOT NULL,
  "dimensions" jsonb NULL DEFAULT '{}',
  "snapshot_date" date NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_metrics_snapshots_metric_name_dimensions_snapshot_da_key" UNIQUE ("metric_name", "dimensions", "snapshot_date")
);
-- Create index "idx_report_metrics_snapshots_metric" to table: "report_metrics_snapshots"
CREATE INDEX "idx_report_metrics_snapshots_metric" ON "public"."report_metrics_snapshots" ("metric_name", "snapshot_date" DESC);
-- Create enum type "supplier_status"
CREATE TYPE "manufacturing"."supplier_status" AS ENUM ('active', 'pending_approval', 'suspended', 'terminated', 'under_review');
-- Create "suppliers" table
CREATE TABLE "manufacturing"."suppliers" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "code" character varying(50) NOT NULL,
  "status" "manufacturing"."supplier_status" NOT NULL DEFAULT 'pending_approval',
  "contact_email" character varying(255) NULL,
  "contact_phone" character varying(50) NULL,
  "address" text NULL,
  "country_code" character varying(3) NULL,
  "tax_id" character varying(50) NULL,
  "payment_terms" integer NULL DEFAULT 30,
  "quality_rating" numeric(3,2) NULL,
  "delivery_rating" numeric(3,2) NULL,
  "cost_rating" numeric(3,2) NULL,
  "risk_score" numeric(5,2) NULL DEFAULT 0,
  "certification_data" jsonb NULL,
  "procurement_manager_id" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "suppliers_code_key" UNIQUE ("code"),
  CONSTRAINT "suppliers_procurement_manager_id_fkey" FOREIGN KEY ("procurement_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "suppliers_cost_rating_check" CHECK ((cost_rating >= (0)::numeric) AND (cost_rating <= (5)::numeric)),
  CONSTRAINT "suppliers_delivery_rating_check" CHECK ((delivery_rating >= (0)::numeric) AND (delivery_rating <= (5)::numeric)),
  CONSTRAINT "suppliers_payment_terms_valid" CHECK ((payment_terms >= 0) AND (payment_terms <= 365)),
  CONSTRAINT "suppliers_quality_rating_check" CHECK ((quality_rating >= (0)::numeric) AND (quality_rating <= (5)::numeric))
);
-- Create "update_supplier_ratings" function
CREATE FUNCTION "manufacturing"."update_supplier_ratings" ("p_supplier_id" integer, "p_quality_rating" numeric DEFAULT NULL::numeric, "p_delivery_rating" numeric DEFAULT NULL::numeric, "p_cost_rating" numeric DEFAULT NULL::numeric, "p_update_risk_score" boolean DEFAULT true) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    v_new_risk_score NUMERIC(5,2);
    v_current_quality NUMERIC(3,2);
    v_current_delivery NUMERIC(3,2);
    v_current_cost NUMERIC(3,2);
BEGIN
    -- Validate ratings
    IF p_quality_rating IS NOT NULL AND (p_quality_rating < 0 OR p_quality_rating > 5) THEN
        RAISE EXCEPTION 'Quality rating must be between 0 and 5';
    END IF;
    
    IF p_delivery_rating IS NOT NULL AND (p_delivery_rating < 0 OR p_delivery_rating > 5) THEN
        RAISE EXCEPTION 'Delivery rating must be between 0 and 5';
    END IF;
    
    IF p_cost_rating IS NOT NULL AND (p_cost_rating < 0 OR p_cost_rating > 5) THEN
        RAISE EXCEPTION 'Cost rating must be between 0 and 5';
    END IF;
    
    -- Update ratings
    UPDATE manufacturing.suppliers 
    SET 
        quality_rating = COALESCE(p_quality_rating, quality_rating),
        delivery_rating = COALESCE(p_delivery_rating, delivery_rating),
        cost_rating = COALESCE(p_cost_rating, cost_rating),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_supplier_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Supplier with ID % not found', p_supplier_id;
    END IF;
    
    -- Calculate and update risk score if requested
    IF p_update_risk_score THEN
        SELECT quality_rating, delivery_rating, cost_rating
        INTO v_current_quality, v_current_delivery, v_current_cost
        FROM manufacturing.suppliers
        WHERE id = p_supplier_id;
        
        -- Risk score calculation: lower ratings = higher risk
        v_new_risk_score := 100 - (
            (COALESCE(v_current_quality, 2.5) + 
             COALESCE(v_current_delivery, 2.5) + 
             COALESCE(v_current_cost, 2.5)) / 3 * 20
        );
        
        UPDATE manufacturing.suppliers 
        SET risk_score = v_new_risk_score
        WHERE id = p_supplier_id;
    END IF;
END;
$$;
-- Create "supplier_tier_history" table
CREATE TABLE "manufacturing"."supplier_tier_history" (
  "id" serial NOT NULL,
  "supplier_id" integer NOT NULL,
  "old_tier" character varying(20) NULL,
  "new_tier" character varying(20) NOT NULL,
  "change_date" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "old_quality_rating" numeric(3,2) NULL,
  "new_quality_rating" numeric(3,2) NULL,
  "old_delivery_rating" numeric(3,2) NULL,
  "new_delivery_rating" numeric(3,2) NULL,
  "old_cost_rating" numeric(3,2) NULL,
  "new_cost_rating" numeric(3,2) NULL,
  "change_reason" text NULL,
  "created_by_user_id" integer NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "supplier_tier_history_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "supplier_tier_history_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "manufacturing"."suppliers" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_supplier_tier_history_date" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_date" ON "manufacturing"."supplier_tier_history" ("change_date" DESC);
-- Create index "idx_supplier_tier_history_supplier" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_supplier" ON "manufacturing"."supplier_tier_history" ("supplier_id");
-- Create index "idx_supplier_tier_history_tier" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_tier" ON "manufacturing"."supplier_tier_history" ("new_tier");
-- Create "supplier_rating_change_notification" function
CREATE FUNCTION "manufacturing"."supplier_rating_change_notification" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_rating_change NUMERIC;
    v_old_tier VARCHAR;
    v_new_tier VARCHAR;
BEGIN
    -- Calculate tier changes when ratings are updated
    IF NEW.quality_rating != OLD.quality_rating OR 
       NEW.delivery_rating != OLD.delivery_rating OR 
       NEW.cost_rating != OLD.cost_rating THEN
        
        -- Calculate old and new supplier tiers
        v_old_tier := CASE 
            WHEN OLD.quality_rating >= 4.5 AND OLD.delivery_rating >= 4.5 THEN 'preferred'
            WHEN OLD.quality_rating >= 3.5 AND OLD.delivery_rating >= 3.5 THEN 'approved'
            WHEN OLD.quality_rating >= 2.5 OR OLD.delivery_rating >= 2.5 THEN 'conditional'
            ELSE 'review_required'
        END;
        
        v_new_tier := CASE 
            WHEN NEW.quality_rating >= 4.5 AND NEW.delivery_rating >= 4.5 THEN 'preferred'
            WHEN NEW.quality_rating >= 3.5 AND NEW.delivery_rating >= 3.5 THEN 'approved'
            WHEN NEW.quality_rating >= 2.5 OR NEW.delivery_rating >= 2.5 THEN 'conditional'
            ELSE 'review_required'
        END;
        
        -- Log tier changes
        IF v_old_tier != v_new_tier THEN
            INSERT INTO manufacturing.supplier_tier_history (
                supplier_id,
                old_tier,
                new_tier,
                change_date,
                old_quality_rating,
                new_quality_rating,
                old_delivery_rating,
                new_delivery_rating,
                old_cost_rating,
                new_cost_rating
            ) VALUES (
                NEW.id,
                v_old_tier,
                v_new_tier,
                CURRENT_TIMESTAMP,
                OLD.quality_rating,
                NEW.quality_rating,
                OLD.delivery_rating,
                NEW.delivery_rating,
                OLD.cost_rating,
                NEW.cost_rating
            );
        END IF;
        
        -- Auto-update risk score
        PERFORM manufacturing.update_supplier_ratings(NEW.id, NULL, NULL, NULL, TRUE);
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create trigger "supplier_rating_update_trigger"
CREATE TRIGGER "supplier_rating_update_trigger" AFTER UPDATE ON "manufacturing"."suppliers" FOR EACH ROW WHEN ((old.quality_rating IS DISTINCT FROM new.quality_rating) OR (old.delivery_rating IS DISTINCT FROM new.delivery_rating) OR (old.cost_rating IS DISTINCT FROM new.cost_rating)) EXECUTE FUNCTION "manufacturing"."supplier_rating_change_notification"();
-- Create enum type "constraint_type"
CREATE TYPE "public"."constraint_type" AS ENUM ('must_start_on', 'must_finish_on', 'start_no_earlier_than', 'start_no_later_than', 'finish_no_earlier_than', 'finish_no_later_than', 'as_soon_as_possible', 'as_late_as_possible');
-- Create trigger "equipment_status_change_trigger"
CREATE TRIGGER "equipment_status_change_trigger" AFTER UPDATE ON "manufacturing"."equipment" FOR EACH ROW WHEN (old.status IS DISTINCT FROM new.status) EXECUTE FUNCTION "manufacturing"."equipment_status_change_notification"();
-- Create trigger "maintenance_work_order_completion_trigger"
CREATE TRIGGER "maintenance_work_order_completion_trigger" BEFORE UPDATE ON "manufacturing"."maintenance_work_orders" FOR EACH ROW EXECUTE FUNCTION "manufacturing"."maintenance_work_order_completion"();
-- Create "t1" table
CREATE TABLE "public"."t1" (
  "c1" serial NOT NULL,
  "c2" integer NOT NULL,
  "c3" integer NOT NULL,
  CONSTRAINT "pk" PRIMARY KEY ("c1")
);
-- Create "security_events" table
CREATE TABLE "public"."security_events" (
  "id" serial NOT NULL,
  "event_type" "public"."security_event_type" NOT NULL,
  "severity" "public"."event_severity" NOT NULL,
  "user_id" integer NULL,
  "ip_address" inet NULL,
  "user_agent" text NULL,
  "endpoint" character varying(200) NULL,
  "event_data" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "security_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_security_events_created" to table: "security_events"
CREATE INDEX "idx_security_events_created" ON "public"."security_events" ("created_at" DESC);
-- Create index "idx_security_events_ip" to table: "security_events"
CREATE INDEX "idx_security_events_ip" ON "public"."security_events" ("ip_address");
-- Create index "idx_security_events_severity" to table: "security_events"
CREATE INDEX "idx_security_events_severity" ON "public"."security_events" ("severity");
-- Create index "idx_security_events_user" to table: "security_events"
CREATE INDEX "idx_security_events_user" ON "public"."security_events" ("user_id");
-- Create "threat_intelligence" table
CREATE TABLE "public"."threat_intelligence" (
  "id" serial NOT NULL,
  "threat_id" character varying(100) NOT NULL,
  "category" "public"."threat_category" NOT NULL,
  "severity" "public"."event_severity" NOT NULL,
  "description" text NOT NULL,
  "indicators" jsonb NOT NULL,
  "first_seen" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "last_seen" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "is_active" boolean NULL DEFAULT true,
  "metadata" jsonb NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "threat_intelligence_threat_id_key" UNIQUE ("threat_id")
);
-- Create index "idx_threat_intelligence_active" to table: "threat_intelligence"
CREATE INDEX "idx_threat_intelligence_active" ON "public"."threat_intelligence" ("is_active", "severity");
-- Create "security_incidents" table
CREATE TABLE "public"."security_incidents" (
  "id" serial NOT NULL,
  "incident_number" character varying(50) NOT NULL,
  "title" character varying(200) NOT NULL,
  "description" text NULL,
  "severity" "public"."event_severity" NOT NULL,
  "status" "public"."incident_status" NOT NULL DEFAULT 'detected',
  "affected_users" integer[] NULL DEFAULT '{}',
  "affected_systems" text[] NULL DEFAULT '{}',
  "threat_intelligence_id" integer NULL,
  "detected_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "contained_at" timestamptz NULL,
  "resolved_at" timestamptz NULL,
  "assigned_to" integer NULL,
  "resolution_notes" text NULL,
  "lessons_learned" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "security_incidents_incident_number_key" UNIQUE ("incident_number"),
  CONSTRAINT "security_incidents_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "security_incidents_threat_intelligence_id_fkey" FOREIGN KEY ("threat_intelligence_id") REFERENCES "public"."threat_intelligence" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_security_incidents_status" to table: "security_incidents"
CREATE INDEX "idx_security_incidents_status" ON "public"."security_incidents" ("status") WHERE (status <> 'resolved'::public.incident_status);
-- Create "check_security_threshold" function
CREATE FUNCTION "public"."check_security_threshold" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_event_count INTEGER;
BEGIN
    -- Check for suspicious activity patterns
    SELECT COUNT(*) INTO v_event_count
    FROM security_events
    WHERE user_id = NEW.user_id
        AND event_type = NEW.event_type
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '5 minutes';
    
    -- If more than 10 similar events in 5 minutes, escalate
    IF v_event_count > 10 AND NEW.severity != 'critical' THEN
        NEW.severity = 'critical';
        
        -- Create incident if not exists
        INSERT INTO security_incidents (
            incident_number,
            title,
            severity,
            affected_users
        ) VALUES (
            'INC-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD-HH24MISS'),
            'Suspicious activity detected for user ' || NEW.user_id,
            'critical',
            ARRAY[NEW.user_id]
        ) ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create trigger "trg_check_security_threshold"
CREATE TRIGGER "trg_check_security_threshold" BEFORE INSERT ON "public"."security_events" FOR EACH ROW EXECUTE FUNCTION "public"."check_security_threshold"();
-- Create "validate_production_run" function
CREATE FUNCTION "manufacturing"."validate_production_run" ("p_production_run_id" integer) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_run RECORD;
    v_line RECORD;
    v_equipment_count INTEGER;
    v_available_equipment INTEGER;
    v_validation_result JSONB;
    v_issues JSONB := '[]'::JSONB;
    v_warnings JSONB := '[]'::JSONB;
    v_is_valid BOOLEAN := TRUE;
BEGIN
    -- Get production run details
    SELECT pr.*, pl.name as line_name, pl.status as line_status, pl.capacity_per_hour
    INTO v_run
    FROM manufacturing.production_runs pr
    JOIN manufacturing.production_lines pl ON pr.production_line_id = pl.id
    WHERE pr.id = p_production_run_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'valid', FALSE,
            'issues', jsonb_build_array('Production run not found')
        );
    END IF;
    
    -- Check production line status
    IF v_run.line_status NOT IN ('running', 'setup') THEN
        v_issues := v_issues || jsonb_build_array(
            'Production line is not operational (status: ' || v_run.line_status || ')'
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check equipment availability
    SELECT 
        COUNT(*),
        COUNT(CASE WHEN status IN ('available', 'running') THEN 1 END)
    INTO v_equipment_count, v_available_equipment
    FROM manufacturing.equipment
    WHERE production_line_id = v_run.production_line_id;
    
    IF v_available_equipment = 0 THEN
        v_issues := v_issues || jsonb_build_array(
            'No equipment available on production line'
        );
        v_is_valid := FALSE;
    ELSIF v_available_equipment < v_equipment_count THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Only ' || v_available_equipment || ' of ' || v_equipment_count || ' equipment units available'
        );
    END IF;
    
    -- Check capacity constraints
    IF v_run.planned_quantity > v_run.capacity_per_hour * 24 THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Planned quantity (' || v_run.planned_quantity || ') exceeds daily capacity (' || 
            (v_run.capacity_per_hour * 24) || ')'
        );
    END IF;
    
    -- Check for scheduling conflicts
    IF EXISTS (
        SELECT 1 FROM manufacturing.production_runs other
        WHERE other.production_line_id = v_run.production_line_id
            AND other.id != v_run.id
            AND other.end_time IS NULL -- Not completed
            AND (
                (v_run.start_time, COALESCE(v_run.end_time, v_run.start_time + INTERVAL '8 hours')) 
                OVERLAPS 
                (other.start_time, COALESCE(other.end_time, other.start_time + INTERVAL '8 hours'))
            )
    ) THEN
        v_issues := v_issues || jsonb_build_array(
            'Scheduling conflict with another production run'
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check material/quality prerequisites
    IF v_run.quality_status NOT IN ('pending', 'pass') THEN
        v_issues := v_issues || jsonb_build_array(
            'Invalid quality status: ' || v_run.quality_status
        );
        v_is_valid := FALSE;
    END IF;
    
    -- Check for maintenance windows
    IF EXISTS (
        SELECT 1 FROM manufacturing.maintenance_work_orders wo
        JOIN manufacturing.equipment e ON wo.equipment_id = e.id
        WHERE e.production_line_id = v_run.production_line_id
            AND wo.status IN ('scheduled', 'in_progress')
            AND (v_run.start_time, COALESCE(v_run.end_time, v_run.start_time + INTERVAL '8 hours'))
                OVERLAPS
                (wo.scheduled_start, wo.scheduled_end)
    ) THEN
        v_warnings := v_warnings || jsonb_build_array(
            'Scheduled maintenance may conflict with production window'
        );
    END IF;
    
    -- Check user assignment
    IF v_run.assigned_user_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.users u
            JOIN public.user_roles ur ON u.id = ur.user_id
            WHERE u.id = v_run.assigned_user_id
                AND u.status = 'active'
                AND ur.role_type IN ('ENG', 'Tech Lead', 'ENG Manager')
        ) THEN
            v_issues := v_issues || jsonb_build_array(
                'Assigned user is not active or does not have appropriate role'
            );
            v_is_valid := FALSE;
        END IF;
    ELSE
        v_warnings := v_warnings || jsonb_build_array(
            'No user assigned to production run'
        );
    END IF;
    
    -- Build validation result
    v_validation_result := jsonb_build_object(
        'production_run_id', p_production_run_id,
        'valid', v_is_valid,
        'validation_timestamp', CURRENT_TIMESTAMP,
        'issues', v_issues,
        'warnings', v_warnings,
        'equipment_status', jsonb_build_object(
            'total_equipment', v_equipment_count,
            'available_equipment', v_available_equipment,
            'availability_pct', ROUND((v_available_equipment::NUMERIC / NULLIF(v_equipment_count, 0)) * 100, 2)
        ),
        'production_run_details', jsonb_build_object(
            'product_code', v_run.product_code,
            'batch_number', v_run.batch_number,
            'planned_quantity', v_run.planned_quantity,
            'production_line', v_run.line_name,
            'line_status', v_run.line_status
        )
    );
    
    RETURN v_validation_result;
END;
$$;
-- Create "task_work_logs" table
CREATE TABLE "public"."task_work_logs" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "hours_worked" numeric(5,2) NOT NULL,
  "work_date" date NOT NULL,
  "description" text NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_work_logs_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_work_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_work_logs_hours_worked_check" CHECK (hours_worked > (0)::numeric)
);
-- Create index "idx_task_work_logs_date" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_date" ON "public"."task_work_logs" ("work_date" DESC);
-- Create index "idx_task_work_logs_task" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_task" ON "public"."task_work_logs" ("task_id");
-- Create index "idx_task_work_logs_user" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_user" ON "public"."task_work_logs" ("user_id");
-- Create "update_task_actual_hours" function
CREATE FUNCTION "public"."update_task_actual_hours" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tasks
    SET actual_hours = (
        SELECT COALESCE(SUM(hours_worked), 0)
        FROM task_work_logs
        WHERE task_id = NEW.task_id
    )
    WHERE id = NEW.task_id;
    
    RETURN NEW;
END;
$$;
-- Create trigger "trg_update_task_actual_hours"
CREATE TRIGGER "trg_update_task_actual_hours" AFTER DELETE OR INSERT OR UPDATE ON "public"."task_work_logs" FOR EACH ROW EXECUTE FUNCTION "public"."update_task_actual_hours"();
-- Create "update_task_search_vector" function
CREATE FUNCTION "public"."update_task_search_vector" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'C');
    RETURN NEW;
END;
$$;
-- Create trigger "trg_update_task_search_vector"
CREATE TRIGGER "trg_update_task_search_vector" BEFORE INSERT OR UPDATE OF "title", "description", "tags" ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."update_task_search_vector"();
-- Create trigger "trg_check_task_dependencies"
CREATE TRIGGER "trg_check_task_dependencies" BEFORE UPDATE OF "status" ON "public"."tasks" FOR EACH ROW WHEN (new.status <> old.status) EXECUTE FUNCTION "public"."check_task_dependencies"();
-- Create "validate_role_assignment" function
CREATE FUNCTION "public"."validate_role_assignment" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Check if user is active
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = NEW.user_id AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Cannot assign role to inactive user';
    END IF;
    
    -- Check for overlapping role assignments
    IF EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = NEW.user_id
          AND id != COALESCE(NEW.id, 0)
          AND effective_from <= COALESCE(NEW.effective_to, '2099-12-31')
          AND (effective_to IS NULL OR effective_to > NEW.effective_from)
    ) THEN
        RAISE EXCEPTION 'User already has an overlapping role assignment';
    END IF;
    
    RETURN NEW;
END;
$$;
-- Create trigger "user_roles_validate_trigger"
CREATE TRIGGER "user_roles_validate_trigger" BEFORE INSERT OR UPDATE ON "public"."user_roles" FOR EACH ROW EXECUTE FUNCTION "public"."validate_role_assignment"();
-- Create "user_audit" table
CREATE TABLE "public"."user_audit" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "operation" character varying(10) NOT NULL,
  "old_values" jsonb NULL,
  "new_values" jsonb NULL,
  "changed_by" integer NULL,
  "changed_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_audit_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "user_audit_operation_valid" CHECK ((operation)::text = ANY (ARRAY[('INSERT'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text]))
);
-- Create index "user_audit_changed_at_idx" to table: "user_audit"
CREATE INDEX "user_audit_changed_at_idx" ON "public"."user_audit" ("changed_at");
-- Create index "user_audit_user_id_idx" to table: "user_audit"
CREATE INDEX "user_audit_user_id_idx" ON "public"."user_audit" ("user_id");
-- Create "audit_user_changes" function
CREATE FUNCTION "public"."audit_user_changes" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO user_audit (user_id, operation, new_values)
        VALUES (NEW.id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO user_audit (user_id, operation, old_values, new_values)
        VALUES (NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO user_audit (user_id, operation, old_values)
        VALUES (OLD.id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;
-- Create trigger "users_audit_trigger"
CREATE TRIGGER "users_audit_trigger" AFTER DELETE OR INSERT OR UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."audit_user_changes"();
-- Create trigger "users_updated_at_trigger"
CREATE TRIGGER "users_updated_at_trigger" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
-- Create "calculate_project_progress" function
CREATE FUNCTION "public"."calculate_project_progress" ("project_id_param" integer) RETURNS numeric LANGUAGE plpgsql STABLE AS $$
DECLARE
    total_tasks integer;
    completed_tasks integer;
    progress numeric;
BEGIN
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE status = 'done')
    INTO total_tasks, completed_tasks
    FROM tasks
    WHERE project_id = project_id_param;
    
    IF total_tasks > 0 THEN
        progress := ROUND(100.0 * completed_tasks / total_tasks, 2);
    ELSE
        progress := 0;
    END IF;
    
    RETURN progress;
END;
$$;
-- Create "calculate_security_risk_score" function
CREATE FUNCTION "public"."calculate_security_risk_score" ("p_user_id" integer) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_risk_score INTEGER := 0;
    v_failed_logins INTEGER;
    v_policy_violations INTEGER;
    v_critical_events INTEGER;
BEGIN
    -- Count failed login attempts in last 24 hours
    SELECT COUNT(*) INTO v_failed_logins
    FROM security_events
    WHERE user_id = p_user_id
        AND event_type = 'login_attempt'
        AND (event_data->>'success')::boolean = false
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours';
    
    -- Count policy violations in last 7 days
    SELECT COUNT(*) INTO v_policy_violations
    FROM security_events
    WHERE user_id = p_user_id
        AND event_type = 'policy_violation'
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days';
    
    -- Count critical events in last 30 days
    SELECT COUNT(*) INTO v_critical_events
    FROM security_events
    WHERE user_id = p_user_id
        AND severity = 'critical'
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Calculate risk score
    v_risk_score := 
        (v_failed_logins * 10) +
        (v_policy_violations * 20) +
        (v_critical_events * 50);
    
    RETURN LEAST(v_risk_score, 100); -- Cap at 100
END;
$$;
-- Create "calculate_task_progress" function
CREATE FUNCTION "public"."calculate_task_progress" ("task_id_param" integer) RETURNS numeric LANGUAGE plpgsql STABLE AS $$
DECLARE
    progress numeric;
    subtask_count integer;
    completed_subtasks integer;
BEGIN
    -- Check if task has subtasks
    SELECT COUNT(*), COUNT(*) FILTER (WHERE status = 'done')
    INTO subtask_count, completed_subtasks
    FROM tasks
    WHERE parent_task_id = task_id_param;
    
    IF subtask_count > 0 THEN
        -- Calculate based on subtasks
        progress := ROUND(100.0 * completed_subtasks / subtask_count, 2);
    ELSE
        -- Use task's own status
        SELECT 
            CASE status
                WHEN 'done' THEN 100
                WHEN 'in_progress' THEN 50
                WHEN 'code_review' THEN 75
                WHEN 'testing' THEN 90
                WHEN 'cancelled' THEN 100
                ELSE 0
            END
        INTO progress
        FROM tasks
        WHERE id = task_id_param;
    END IF;
    
    RETURN COALESCE(progress, 0);
END;
$$;
-- Create "calculate_working_days" function
CREATE FUNCTION "public"."calculate_working_days" ("start_date" date, "end_date" date, "working_days" integer[] DEFAULT '{1,2,3,4,5}', "holidays" date[] DEFAULT '{}') RETURNS integer LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    days_count integer := 0;
    current_day date;
BEGIN
    current_day := start_date;
    WHILE current_day <= end_date LOOP
        IF EXTRACT(dow FROM current_day)::integer = ANY(working_days) 
           AND current_day != ALL(holidays) THEN
            days_count := days_count + 1;
        END IF;
        current_day := current_day + 1;
    END LOOP;
    RETURN days_count;
END;
$$;
-- Create "schedule_preventive_maintenance" function
CREATE FUNCTION "manufacturing"."schedule_preventive_maintenance" ("p_equipment_id" integer, "p_maintenance_interval_days" integer DEFAULT 90, "p_estimated_hours" numeric DEFAULT 8.0, "p_assigned_technician_id" integer DEFAULT NULL::integer) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_work_order_id INTEGER;
    v_work_order_number VARCHAR;
    v_next_maintenance_date TIMESTAMPTZ;
    v_equipment_name VARCHAR;
BEGIN
    -- Get equipment details
    SELECT name, 
           COALESCE(next_maintenance, CURRENT_TIMESTAMP + INTERVAL '1 day')
    INTO v_equipment_name, v_next_maintenance_date
    FROM manufacturing.equipment 
    WHERE id = p_equipment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Equipment with ID % not found', p_equipment_id;
    END IF;
    
    -- Generate work order number
    v_work_order_number := 'PM-' || p_equipment_id || '-' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::BIGINT;
    
    -- Create preventive maintenance work order
    INSERT INTO manufacturing.maintenance_work_orders (
        work_order_number,
        equipment_id,
        maintenance_type,
        status,
        priority_level,
        title,
        description,
        assigned_technician_id,
        estimated_hours,
        scheduled_start,
        scheduled_end
    ) VALUES (
        v_work_order_number,
        p_equipment_id,
        'preventive',
        'scheduled',
        'medium',
        'Preventive Maintenance - ' || v_equipment_name,
        'Scheduled preventive maintenance for equipment: ' || v_equipment_name,
        p_assigned_technician_id,
        p_estimated_hours,
        v_next_maintenance_date,
        v_next_maintenance_date + (p_estimated_hours || ' hours')::INTERVAL
    ) RETURNING id INTO v_work_order_id;
    
    -- Update equipment next maintenance date
    UPDATE manufacturing.equipment 
    SET next_maintenance = v_next_maintenance_date + (p_maintenance_interval_days || ' days')::INTERVAL
    WHERE id = p_equipment_id;
    
    RETURN v_work_order_id;
END;
$$;
-- Create "correlate_security_events" function
CREATE FUNCTION "public"."correlate_security_events" ("p_user_id" integer, "p_time_window" interval DEFAULT '01:00:00'::interval) RETURNS TABLE ("event_type" "public"."security_event_type", "event_count" bigint, "unique_ips" bigint, "severity_distribution" jsonb) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        se.event_type,
        COUNT(*) as event_count,
        COUNT(DISTINCT se.ip_address) as unique_ips,
        jsonb_object_agg(se.severity, severity_count) as severity_distribution
    FROM security_events se
    WHERE se.user_id = p_user_id
        AND se.created_at >= CURRENT_TIMESTAMP - p_time_window
    GROUP BY se.event_type
    HAVING COUNT(*) > 1;
END;
$$;
-- Create "gantt_schedules" table
CREATE TABLE "public"."gantt_schedules" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "name" character varying(200) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "critical_path" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "end_date_2" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_schedules_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_gantt_schedules_project" to table: "gantt_schedules"
CREATE INDEX "idx_gantt_schedules_project" ON "public"."gantt_schedules" ("project_id");
-- Create "gantt_tasks" table
CREATE TABLE "public"."gantt_tasks" (
  "id" serial NOT NULL,
  "schedule_id" integer NOT NULL,
  "task_id" integer NULL,
  "name" character varying(200) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "duration" integer NOT NULL,
  "progress" numeric(5,2) NULL DEFAULT 0,
  "is_milestone" boolean NULL DEFAULT false,
  "parent_task_id" integer NULL,
  "position" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_tasks_parent_task_id_fkey" FOREIGN KEY ("parent_task_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_tasks_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "public"."gantt_schedules" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_tasks_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_gantt_tasks_parent" to table: "gantt_tasks"
CREATE INDEX "idx_gantt_tasks_parent" ON "public"."gantt_tasks" ("parent_task_id");
-- Create index "idx_gantt_tasks_schedule" to table: "gantt_tasks"
CREATE INDEX "idx_gantt_tasks_schedule" ON "public"."gantt_tasks" ("schedule_id");
-- Create "gantt_resource_assignments" table
CREATE TABLE "public"."gantt_resource_assignments" (
  "id" serial NOT NULL,
  "gantt_task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "allocation_percentage" numeric(5,2) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "hello_world" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_resource_assignments_gantt_task_id_user_id_key" UNIQUE ("gantt_task_id", "user_id"),
  CONSTRAINT "gantt_resource_assignments_gantt_task_id_fkey" FOREIGN KEY ("gantt_task_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_resource_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_resource_assignments_allocation_percentage_check" CHECK ((allocation_percentage > (0)::numeric) AND (allocation_percentage <= (100)::numeric))
);
-- Create index "idx_gantt_resource_assignments_user" to table: "gantt_resource_assignments"
CREATE INDEX "idx_gantt_resource_assignments_user" ON "public"."gantt_resource_assignments" ("user_id");
-- Create "detect_resource_conflicts" function
CREATE FUNCTION "public"."detect_resource_conflicts" ("schedule_id_param" integer) RETURNS TABLE ("user_id" integer, "conflict_date" date, "total_allocation" numeric, "conflict_severity" "public"."resource_conflict_severity", "conflicting_tasks" integer[]) LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH daily_allocations AS (
        SELECT 
            ra.user_id,
            d.date,
            SUM(ra.allocation_percentage) as total_allocation,
            array_agg(ra.gantt_task_id) as task_ids
        FROM gantt_resource_assignments ra
        JOIN gantt_tasks gt ON gt.id = ra.gantt_task_id
        CROSS JOIN LATERAL generate_series(ra.start_date, ra.end_date, '1 day'::interval) d(date)
        WHERE gt.schedule_id = schedule_id_param
        GROUP BY ra.user_id, d.date
        HAVING SUM(ra.allocation_percentage) > 100
    )
    SELECT 
        da.user_id,
        da.date::date as conflict_date,
        da.total_allocation,
        CASE 
            WHEN da.total_allocation > 200 THEN 'severe'::resource_conflict_severity
            WHEN da.total_allocation > 150 THEN 'high'::resource_conflict_severity
            WHEN da.total_allocation > 120 THEN 'medium'::resource_conflict_severity
            ELSE 'low'::resource_conflict_severity
        END as conflict_severity,
        da.task_ids as conflicting_tasks
    FROM daily_allocations da
    ORDER BY da.total_allocation DESC, da.date;
END;
$$;
-- Create "project_team_members" table
CREATE TABLE "public"."project_team_members" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "role" character varying(100) NOT NULL,
  "allocation_percentage" integer NOT NULL DEFAULT 100,
  "start_date" date NOT NULL DEFAULT CURRENT_DATE,
  "end_date" date NULL,
  "hourly_rate" numeric(8,2) NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_team_members_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_team_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_team_allocation_valid" CHECK ((allocation_percentage > 0) AND (allocation_percentage <= 100)),
  CONSTRAINT "project_team_dates_valid" CHECK ((end_date IS NULL) OR (end_date >= start_date)),
  CONSTRAINT "project_team_hourly_rate_positive" CHECK ((hourly_rate IS NULL) OR (hourly_rate >= (0)::numeric))
);
-- Create index "project_team_active_idx" to table: "project_team_members"
CREATE INDEX "project_team_active_idx" ON "public"."project_team_members" ("project_id", "user_id") WHERE (end_date IS NULL);
-- Create index "project_team_project_idx" to table: "project_team_members"
CREATE INDEX "project_team_project_idx" ON "public"."project_team_members" ("project_id");
-- Create index "project_team_user_idx" to table: "project_team_members"
CREATE INDEX "project_team_user_idx" ON "public"."project_team_members" ("user_id");
-- Create "generate_project_metrics" function
CREATE FUNCTION "public"."generate_project_metrics" ("project_id_param" integer, "as_of_date" date DEFAULT CURRENT_DATE) RETURNS jsonb LANGUAGE plpgsql STABLE AS $$
DECLARE
    metrics jsonb;
BEGIN
    SELECT jsonb_build_object(
        'project_id', project_id_param,
        'as_of_date', as_of_date,
        'completion_percentage', calculate_project_progress(project_id_param),
        'total_tasks', COUNT(*),
        'completed_tasks', COUNT(*) FILTER (WHERE status = 'done'),
        'active_tasks', COUNT(*) FILTER (WHERE status = 'in_progress'),
        'blocked_tasks', COUNT(*) FILTER (WHERE status = 'blocked'),
        'overdue_tasks', COUNT(*) FILTER (WHERE due_date < as_of_date AND status != 'done'),
        'total_estimated_hours', COALESCE(SUM(estimated_hours), 0),
        'total_actual_hours', COALESCE(SUM(actual_hours), 0),
        'team_size', (SELECT COUNT(DISTINCT user_id) FROM project_team_members WHERE project_id = project_id_param AND (end_date IS NULL OR end_date >= CURRENT_DATE))
    ) INTO metrics
    FROM tasks
    WHERE project_id = project_id_param;
    
    RETURN metrics;
END;
$$;
-- Create "get_current_user_role" function
CREATE FUNCTION "public"."get_current_user_role" ("user_id_param" integer) RETURNS "public"."user_role_type" LANGUAGE plpgsql AS $$
BEGIN
    RETURN (
        SELECT role
        FROM user_roles
        WHERE user_id = user_id_param
          AND effective_from <= CURRENT_DATE
          AND (effective_to IS NULL OR effective_to > CURRENT_DATE)
        ORDER BY effective_from DESC
        LIMIT 1
    );
END;
$$;
-- Create "get_device_telemetry_summary" function
CREATE FUNCTION "public"."get_device_telemetry_summary" ("p_device_id" integer, "p_start_time" timestamptz, "p_end_time" timestamptz) RETURNS TABLE ("sensor_type" "public"."sensor_type", "avg_value" numeric, "min_value" numeric, "max_value" numeric, "reading_count" bigint, "anomaly_count" bigint) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sd.sensor_type,
        AVG(sd.value) as avg_value,
        MIN(sd.value) as min_value,
        MAX(sd.value) as max_value,
        COUNT(*) as reading_count,
        COUNT(CASE WHEN check_sensor_anomaly(p_device_id, sd.sensor_type, sd.value) THEN 1 END) as anomaly_count
    FROM iot_sensor_data sd
    WHERE sd.device_id = p_device_id
        AND sd.timestamp BETWEEN p_start_time AND p_end_time
    GROUP BY sd.sensor_type;
END;
$$;
-- Create "get_project_hierarchy" function
CREATE FUNCTION "public"."get_project_hierarchy" ("project_id_param" integer) RETURNS TABLE ("id" integer, "parent_id" integer, "level" integer, "path" integer[], "name" character varying, "code" character varying) LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE project_tree AS (
    SELECT 
        p.id,
        p.parent_project_id as parent_id,
        0 as level,
        ARRAY[p.id] as path,
        p.name,
        p.code
    FROM projects p
    WHERE p.id = project_id_param
    
    UNION ALL
    
    SELECT 
        p.id,
        p.parent_project_id,
        pt.level + 1,
        pt.path || p.id,
        p.name,
        p.code
    FROM projects p
    JOIN project_tree pt ON p.parent_project_id = pt.id
)
SELECT * FROM project_tree
ORDER BY path;
END;
$$;
-- Create "get_task_hierarchy" function
CREATE FUNCTION "public"."get_task_hierarchy" ("task_id_param" integer) RETURNS TABLE ("id" integer, "parent_id" integer, "level" integer, "path" integer[], "title" character varying, "task_key" character varying, "status" "public"."task_status") LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE task_tree AS (
    SELECT 
        t.id,
        t.parent_task_id as parent_id,
        0 as level,
        ARRAY[t.id] as path,
        t.title,
        t.task_key,
        t.status
    FROM tasks t
    WHERE t.id = task_id_param
    
    UNION ALL
    
    SELECT 
        t.id,
        t.parent_task_id,
        tt.level + 1,
        tt.path || t.id,
        t.title,
        t.task_key,
        t.status
    FROM tasks t
    JOIN task_tree tt ON t.parent_task_id = tt.id
)
SELECT * FROM task_tree
ORDER BY path;
END;
$$;
-- Create "level_resources" function
CREATE FUNCTION "public"."level_resources" ("schedule_id_param" integer) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    conflict_record RECORD;
    task_record RECORD;
    available_capacity numeric;
BEGIN
    -- Process each conflict
    FOR conflict_record IN 
        SELECT * FROM detect_resource_conflicts(schedule_id_param)
        ORDER BY conflict_severity DESC, conflict_date
    LOOP
        available_capacity := 100;
        
        -- Redistribute allocation for conflicting tasks
        FOR task_record IN
            SELECT ra.*
            FROM gantt_resource_assignments ra
            WHERE ra.gantt_task_id = ANY(conflict_record.conflicting_tasks)
                AND ra.user_id = conflict_record.user_id
            ORDER BY ra.allocation_percentage DESC
        LOOP
            IF available_capacity > 0 THEN
                UPDATE gantt_resource_assignments
                SET allocation_percentage = LEAST(task_record.allocation_percentage, available_capacity)
                WHERE id = task_record.id;
                
                available_capacity := available_capacity - LEAST(task_record.allocation_percentage, available_capacity);
            ELSE
                -- Shift task dates if no capacity available
                UPDATE gantt_resource_assignments
                SET start_date = start_date + INTERVAL '1 day',
                    end_date = end_date + INTERVAL '1 day'
                WHERE id = task_record.id;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;
-- Create enum type "order_status"
CREATE TYPE "manufacturing"."order_status" AS ENUM ('draft', 'pending_approval', 'approved', 'sent', 'acknowledged', 'in_transit', 'delivered', 'completed', 'cancelled');
-- Create "gantt_task_dependencies" table
CREATE TABLE "public"."gantt_task_dependencies" (
  "id" serial NOT NULL,
  "predecessor_id" integer NOT NULL,
  "successor_id" integer NOT NULL,
  "dependency_type" character varying(10) NOT NULL,
  "lag_days" integer NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_task_dependencies_predecessor_id_successor_id_key" UNIQUE ("predecessor_id", "successor_id"),
  CONSTRAINT "gantt_task_dependencies_predecessor_id_fkey" FOREIGN KEY ("predecessor_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_task_dependencies_successor_id_fkey" FOREIGN KEY ("successor_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_task_dependencies_dependency_type_check" CHECK ((dependency_type)::text = ANY (ARRAY[('FS'::character varying)::text, ('FF'::character varying)::text, ('SS'::character varying)::text, ('SF'::character varying)::text]))
);
-- Create "iot_device_alerts" table
CREATE TABLE "public"."iot_device_alerts" (
  "id" serial NOT NULL,
  "device_id" integer NOT NULL,
  "sensor_type" "public"."sensor_type" NULL,
  "severity" "public"."alert_severity" NOT NULL,
  "status" "public"."alert_status" NOT NULL DEFAULT 'open',
  "condition" character varying(200) NOT NULL,
  "threshold_value" numeric NULL,
  "actual_value" numeric NULL,
  "alert_message" text NOT NULL,
  "triggered_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "acknowledged_at" timestamptz NULL,
  "resolved_at" timestamptz NULL,
  "acknowledged_by" integer NULL,
  "resolution_notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_device_alerts_acknowledged_by_fkey" FOREIGN KEY ("acknowledged_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "iot_device_alerts_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "public"."iot_devices" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_iot_device_alerts_device" to table: "iot_device_alerts"
CREATE INDEX "idx_iot_device_alerts_device" ON "public"."iot_device_alerts" ("device_id");
-- Create index "idx_iot_device_alerts_status" to table: "iot_device_alerts"
CREATE INDEX "idx_iot_device_alerts_status" ON "public"."iot_device_alerts" ("status") WHERE (status = ANY (ARRAY['open'::public.alert_status, 'acknowledged'::public.alert_status]));
-- Create "report_templates" table
CREATE TABLE "public"."report_templates" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "description" text NULL,
  "template_type" character varying(50) NOT NULL,
  "query_template" text NOT NULL,
  "parameters" jsonb NULL DEFAULT '{}',
  "layout" jsonb NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "report_subscriptions" table
CREATE TABLE "public"."report_subscriptions" (
  "id" serial NOT NULL,
  "template_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "schedule" character varying(50) NOT NULL,
  "parameters" jsonb NULL DEFAULT '{}',
  "last_run" timestamptz NULL,
  "next_run" timestamptz NULL,
  "is_active" boolean NULL DEFAULT true,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_subscriptions_template_id_user_id_key" UNIQUE ("template_id", "user_id"),
  CONSTRAINT "report_subscriptions_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."report_templates" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "report_subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_report_subscriptions_active" to table: "report_subscriptions"
CREATE INDEX "idx_report_subscriptions_active" ON "public"."report_subscriptions" ("is_active", "next_run");
-- Create index "idx_report_subscriptions_user" to table: "report_subscriptions"
CREATE INDEX "idx_report_subscriptions_user" ON "public"."report_subscriptions" ("user_id");
-- Create "resource_calendars" table
CREATE TABLE "public"."resource_calendars" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "date" date NOT NULL,
  "is_working_day" boolean NULL DEFAULT true,
  "working_hours" numeric(4,2) NULL DEFAULT 8,
  "notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "resource_calendars_user_id_date_key" UNIQUE ("user_id", "date"),
  CONSTRAINT "resource_calendars_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_resource_calendars_user_date" to table: "resource_calendars"
CREATE INDEX "idx_resource_calendars_user_date" ON "public"."resource_calendars" ("user_id", "date");
-- Create "status_reports" table
CREATE TABLE "public"."status_reports" (
  "id" serial NOT NULL,
  "project_id" integer NOT NULL,
  "reporting_period_start" date NOT NULL,
  "reporting_period_end" date NOT NULL,
  "overall_status" "public"."project_status_type" NOT NULL,
  "summary" text NOT NULL,
  "achievements" text NULL,
  "issues" text NULL,
  "next_steps" text NULL,
  "metrics" jsonb NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "reporting_period_start_2" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "status_reports_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "status_reports_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_status_reports_project" to table: "status_reports"
CREATE INDEX "idx_status_reports_project" ON "public"."status_reports" ("project_id", "reporting_period_end" DESC);
-- Create "task_comments" table
CREATE TABLE "public"."task_comments" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "comment" text NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_comments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_task_comments_task" to table: "task_comments"
CREATE INDEX "idx_task_comments_task" ON "public"."task_comments" ("task_id");
-- Create index "idx_task_comments_user" to table: "task_comments"
CREATE INDEX "idx_task_comments_user" ON "public"."task_comments" ("user_id");
-- Create "technician_workload_distribution" view
CREATE VIEW "manufacturing"."technician_workload_distribution" (
  "technician_id",
  "technician_name",
  "technician_email",
  "total_assigned_orders",
  "pending_orders",
  "active_orders",
  "completed_orders",
  "total_estimated_hours",
  "total_actual_hours",
  "avg_time_variance",
  "remaining_workload_hours",
  "high_priority_orders",
  "maintenance_specialties"
) AS SELECT u.id AS technician_id,
    (u.first_name::text || ' '::text) || u.last_name::text AS technician_name,
    u.email AS technician_email,
    count(*) AS total_assigned_orders,
    count(
        CASE
            WHEN wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status]) THEN 1
            ELSE NULL::integer
        END) AS pending_orders,
    count(
        CASE
            WHEN wo.status = 'in_progress'::manufacturing.work_order_status THEN 1
            ELSE NULL::integer
        END) AS active_orders,
    count(
        CASE
            WHEN wo.status = 'completed'::manufacturing.work_order_status THEN 1
            ELSE NULL::integer
        END) AS completed_orders,
    sum(wo.estimated_hours) AS total_estimated_hours,
    sum(wo.actual_hours) AS total_actual_hours,
    avg(wo.actual_hours / NULLIF(wo.estimated_hours, 0::numeric)) AS avg_time_variance,
    sum(
        CASE
            WHEN wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status, 'in_progress'::manufacturing.work_order_status]) THEN wo.estimated_hours
            ELSE 0::numeric
        END) AS remaining_workload_hours,
    count(
        CASE
            WHEN wo.priority_level = 'high'::public.priority_level THEN 1
            ELSE NULL::integer
        END) AS high_priority_orders,
    string_agg(DISTINCT wo.maintenance_type::text, ', '::text) AS maintenance_specialties
   FROM public.users u
     JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
  WHERE wo.created_at >= (CURRENT_DATE - '6 mons'::interval)
  GROUP BY u.id, u.first_name, u.last_name, u.email;
-- Create "supplier_performance_scorecard" view
CREATE VIEW "manufacturing"."supplier_performance_scorecard" (
  "supplier_id",
  "supplier_name",
  "supplier_code",
  "status",
  "quality_rating",
  "delivery_rating",
  "cost_rating",
  "risk_score",
  "procurement_manager",
  "supplier_tier",
  "overall_score"
) AS SELECT s.id AS supplier_id,
    s.name AS supplier_name,
    s.code AS supplier_code,
    s.status,
    s.quality_rating,
    s.delivery_rating,
    s.cost_rating,
    s.risk_score,
    (u.first_name::text || ' '::text) || u.last_name::text AS procurement_manager,
        CASE
            WHEN s.quality_rating >= 4.5 AND s.delivery_rating >= 4.5 THEN 'preferred'::text
            WHEN s.quality_rating >= 3.5 AND s.delivery_rating >= 3.5 THEN 'approved'::text
            WHEN s.quality_rating >= 2.5 OR s.delivery_rating >= 2.5 THEN 'conditional'::text
            ELSE 'review_required'::text
        END AS supplier_tier,
    (s.quality_rating + s.delivery_rating + s.cost_rating) / 3::numeric AS overall_score
   FROM manufacturing.suppliers s
     LEFT JOIN public.users u ON s.procurement_manager_id = u.id
  WHERE s.status <> 'terminated'::manufacturing.supplier_status;
-- Create "project_manufacturing_status" view
CREATE VIEW "manufacturing"."project_manufacturing_status" (
  "project_id",
  "project_name",
  "project_status",
  "assigned_production_lines",
  "total_production_runs",
  "total_planned_quantity",
  "total_actual_quantity",
  "passed_runs",
  "failed_runs",
  "first_production_start",
  "last_production_end",
  "related_work_orders",
  "total_maintenance_costs",
  "production_line_names"
) AS SELECT p.id AS project_id,
    p.name AS project_name,
    p.status AS project_status,
    count(DISTINCT pl.id) AS assigned_production_lines,
    count(DISTINCT pr.id) AS total_production_runs,
    sum(pr.planned_quantity) AS total_planned_quantity,
    sum(pr.actual_quantity) AS total_actual_quantity,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS passed_runs,
    count(
        CASE
            WHEN pr.quality_status = ANY (ARRAY['fail'::manufacturing.quality_status, 'rework'::manufacturing.quality_status]) THEN 1
            ELSE NULL::integer
        END) AS failed_runs,
    min(pr.start_time) AS first_production_start,
    max(pr.end_time) AS last_production_end,
    count(DISTINCT wo.id) AS related_work_orders,
    sum(wo.actual_cost) AS total_maintenance_costs,
    string_agg(DISTINCT pl.name::text, ', '::text) AS production_line_names
   FROM public.projects p
     LEFT JOIN manufacturing.production_lines pl ON p.id = pl.project_id
     LEFT JOIN manufacturing.production_runs pr ON p.id = pr.project_id
     LEFT JOIN manufacturing.equipment e ON pl.id = e.production_line_id
     LEFT JOIN manufacturing.maintenance_work_orders wo ON e.id = wo.equipment_id AND wo.created_at >= p.created_at
  GROUP BY p.id, p.name, p.status;
-- Create "production_quality_trends" view
CREATE VIEW "manufacturing"."production_quality_trends" (
  "production_date",
  "production_line_name",
  "product_code",
  "total_batches",
  "planned_total",
  "actual_total",
  "yield_percentage",
  "passed_batches",
  "failed_batches",
  "rework_batches",
  "pass_rate",
  "avg_batch_hours"
) AS SELECT date_trunc('day'::text, pr.created_at) AS production_date,
    pl.name AS production_line_name,
    pr.product_code,
    count(*) AS total_batches,
    sum(pr.planned_quantity) AS planned_total,
    sum(pr.actual_quantity) AS actual_total,
    sum(pr.actual_quantity) / NULLIF(sum(pr.planned_quantity), 0) * 100 AS yield_percentage,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS passed_batches,
    count(
        CASE
            WHEN pr.quality_status = 'fail'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS failed_batches,
    count(
        CASE
            WHEN pr.quality_status = 'rework'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS rework_batches,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) / NULLIF(count(*), 0) * 100 AS pass_rate,
    avg(EXTRACT(epoch FROM pr.end_time - pr.start_time) / 3600::numeric) AS avg_batch_hours
   FROM manufacturing.production_runs pr
     JOIN manufacturing.production_lines pl ON pr.production_line_id = pl.id
  WHERE pr.created_at >= (CURRENT_DATE - '90 days'::interval) AND pr.end_time IS NOT NULL
  GROUP BY (date_trunc('day'::text, pr.created_at)), pl.name, pr.product_code;
-- Create "production_line_efficiency" view
CREATE VIEW "manufacturing"."production_line_efficiency" (
  "production_line_id",
  "production_line_name",
  "capacity_per_hour",
  "total_runs",
  "total_output",
  "avg_output_per_run",
  "efficiency_percentage",
  "quality_pass_rate"
) AS SELECT pl.id AS production_line_id,
    pl.name AS production_line_name,
    pl.capacity_per_hour,
    count(pr.id) AS total_runs,
    sum(pr.actual_quantity) AS total_output,
    avg(pr.actual_quantity) AS avg_output_per_run,
    sum(pr.actual_quantity)::numeric / NULLIF(pl.capacity_per_hour::numeric * EXTRACT(epoch FROM max(pr.end_time) - min(pr.start_time)) / 3600::numeric, 0::numeric) * 100::numeric AS efficiency_percentage,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) / NULLIF(count(pr.id), 0) * 100 AS quality_pass_rate
   FROM manufacturing.production_lines pl
     LEFT JOIN manufacturing.production_runs pr ON pl.id = pr.production_line_id AND pr.start_time >= (CURRENT_DATE - '30 days'::interval) AND pr.end_time IS NOT NULL
  GROUP BY pl.id, pl.name, pl.capacity_per_hour;
-- Create "iot_device_health" view
CREATE VIEW "public"."iot_device_health" (
  "id",
  "serial_number",
  "status",
  "last_seen",
  "connectivity_status",
  "active_alerts",
  "model_name",
  "manufacturer"
) AS SELECT d.id,
    d.serial_number,
    d.status,
    d.last_seen,
        CASE
            WHEN d.last_seen IS NULL THEN 'never_seen'::text
            WHEN d.last_seen < (CURRENT_TIMESTAMP - '01:00:00'::interval) THEN 'offline'::text
            WHEN d.last_seen < (CURRENT_TIMESTAMP - '00:10:00'::interval) THEN 'delayed'::text
            ELSE 'online'::text
        END AS connectivity_status,
    count(DISTINCT a.id) FILTER (WHERE a.status = ANY (ARRAY['open'::public.alert_status, 'acknowledged'::public.alert_status])) AS active_alerts,
    dm.name AS model_name,
    dm.manufacturer
   FROM public.iot_devices d
     JOIN public.iot_device_models dm ON d.device_model_id = dm.id
     LEFT JOIN public.iot_device_alerts a ON d.id = a.device_id
  GROUP BY d.id, d.serial_number, d.status, d.last_seen, dm.name, dm.manufacturer;
-- Create "project_portfolio_dashboard" view
CREATE VIEW "public"."project_portfolio_dashboard" (
  "id",
  "code",
  "name",
  "project_type",
  "status",
  "priority",
  "planned_start",
  "planned_end",
  "actual_start",
  "actual_end",
  "budget_allocated",
  "budget_spent",
  "budget_utilization",
  "project_manager",
  "tech_lead",
  "total_tasks",
  "completed_tasks",
  "active_tasks",
  "high_priority_tasks",
  "team_size",
  "last_activity"
) AS SELECT p.id,
    p.code,
    p.name,
    p.project_type,
    p.status,
    p.priority,
    p.planned_start,
    p.planned_end,
    p.actual_start,
    p.actual_end,
    p.budget_allocated,
    p.budget_spent,
    round(100.0 * p.budget_spent / NULLIF(p.budget_allocated, 0::numeric), 2) AS budget_utilization,
    (pm_user.first_name::text || ' '::text) || pm_user.last_name::text AS project_manager,
    (tl_user.first_name::text || ' '::text) || tl_user.last_name::text AS tech_lead,
    count(DISTINCT t.id) AS total_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'in_progress'::public.task_status) AS active_tasks,
    count(DISTINCT t.id) FILTER (WHERE t.priority = ANY (ARRAY['high'::public.priority_level, 'critical'::public.priority_level])) AS high_priority_tasks,
    count(DISTINCT tm.user_id) AS team_size,
    max(t.updated_at) AS last_activity
   FROM public.projects p
     LEFT JOIN public.users pm_user ON p.project_manager_id = pm_user.id
     LEFT JOIN public.users tl_user ON p.tech_lead_id = tl_user.id
     LEFT JOIN public.tasks t ON t.project_id = p.id
     LEFT JOIN public.project_team_members tm ON tm.project_id = p.id AND (tm.end_date IS NULL OR tm.end_date >= CURRENT_DATE)
  GROUP BY p.id, p.code, p.name, p.project_type, p.status, p.priority, p.planned_start, p.planned_end, p.actual_start, p.actual_end, p.budget_allocated, p.budget_spent, pm_user.first_name, pm_user.last_name, tl_user.first_name, tl_user.last_name;
-- Create "role_summary" view
CREATE VIEW "public"."role_summary" (
  "role",
  "total_users",
  "current_users",
  "first_assignment",
  "latest_assignment"
) AS SELECT role,
    count(*) AS total_users,
    count(*) FILTER (WHERE effective_to IS NULL AND effective_from <= CURRENT_DATE) AS current_users,
    min(effective_from) AS first_assignment,
    max(effective_from) AS latest_assignment
   FROM public.user_roles
  GROUP BY role
  ORDER BY role;
-- Create "security_dashboard" view
CREATE VIEW "public"."security_dashboard" (
  "date",
  "total_events",
  "unique_users",
  "critical_events",
  "high_events",
  "failed_logins",
  "access_denied",
  "events_by_type"
) AS SELECT date(created_at) AS date,
    count(*) AS total_events,
    count(DISTINCT user_id) AS unique_users,
    count(*) FILTER (WHERE severity = 'critical'::public.event_severity) AS critical_events,
    count(*) FILTER (WHERE severity = 'high'::public.event_severity) AS high_events,
    count(*) FILTER (WHERE event_type = 'login_attempt'::public.security_event_type AND ((event_data ->> 'success'::text)::boolean) = false) AS failed_logins,
    count(*) FILTER (WHERE event_type = 'access_denied'::public.security_event_type) AS access_denied,
    jsonb_object_agg(event_type, type_count) AS events_by_type
   FROM ( SELECT security_events.created_at,
            security_events.user_id,
            security_events.severity,
            security_events.event_type,
            security_events.event_data,
            count(*) OVER (PARTITION BY security_events.event_type) AS type_count
           FROM public.security_events
          WHERE security_events.created_at >= (CURRENT_DATE - '30 days'::interval)) se
  GROUP BY (date(created_at));
-- Create "sprint_velocity" view
CREATE VIEW "public"."sprint_velocity" (
  "sprint_id",
  "phase_id",
  "sprint_name",
  "start_date",
  "end_date",
  "total_tasks",
  "completed_tasks",
  "completion_rate",
  "completed_hours",
  "actual_hours",
  "velocity_ratio"
) AS WITH sprint_metrics AS (
         SELECT t.sprint_id,
            t.sprint_id AS phase_id,
            'Sprint '::text || t.sprint_id AS sprint_name,
            min(t.start_date) AS start_date,
            max(t.due_date) AS end_date,
            count(DISTINCT t.id) AS total_tasks,
            count(DISTINCT t.id) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_tasks,
            sum(t.estimated_hours) FILTER (WHERE t.status = 'done'::public.task_status) AS completed_hours,
            sum(t.actual_hours) FILTER (WHERE t.status = 'done'::public.task_status) AS actual_hours
           FROM public.tasks t
          WHERE t.sprint_id IS NOT NULL
          GROUP BY t.sprint_id
        )
 SELECT sprint_id,
    phase_id,
    sprint_name,
    start_date,
    end_date,
    total_tasks,
    completed_tasks,
    round(100.0 * completed_tasks::numeric / NULLIF(total_tasks, 0)::numeric, 2) AS completion_rate,
    completed_hours,
    actual_hours,
    round(completed_hours / NULLIF(actual_hours, 0::numeric), 2) AS velocity_ratio
   FROM sprint_metrics
  ORDER BY start_date DESC;
-- Create "task_burndown" view
CREATE VIEW "public"."task_burndown" (
  "date",
  "project_id",
  "project_name",
  "total_created",
  "total_completed",
  "remaining_tasks"
) AS WITH dates AS (
         SELECT generate_series(date_trunc('month'::text, CURRENT_DATE - '3 mons'::interval), CURRENT_DATE::timestamp without time zone, '1 day'::interval)::date AS date
        ), daily_status AS (
         SELECT d.date,
            p.id AS project_id,
            p.name AS project_name,
            count(t.id) FILTER (WHERE t.created_at::date <= d.date) AS total_created,
            count(t.id) FILTER (WHERE t.status = 'done'::public.task_status AND t.updated_at::date <= d.date) AS total_completed,
            count(t.id) FILTER (WHERE t.created_at::date <= d.date AND (t.status <> 'done'::public.task_status OR t.updated_at::date > d.date)) AS remaining_tasks
           FROM dates d
             CROSS JOIN public.projects p
             LEFT JOIN public.tasks t ON t.project_id = p.id
          WHERE p.status = ANY (ARRAY['active'::public.project_status_type, 'testing'::public.project_status_type, 'deployment'::public.project_status_type])
          GROUP BY d.date, p.id, p.name
        )
 SELECT date,
    project_id,
    project_name,
    total_created,
    total_completed,
    remaining_tasks
   FROM daily_status
  WHERE total_created > 0
  ORDER BY project_id, date;
-- Create "iot_sensor_daily_stats" view
CREATE MATERIALIZED VIEW "public"."iot_sensor_daily_stats" (
  "device_id",
  "sensor_type",
  "date",
  "reading_count",
  "avg_value",
  "min_value",
  "max_value",
  "stddev_value",
  "avg_quality"
) AS SELECT device_id,
    sensor_type,
    date("timestamp") AS date,
    count(*) AS reading_count,
    avg(value) AS avg_value,
    min(value) AS min_value,
    max(value) AS max_value,
    stddev(value) AS stddev_value,
    avg(quality_score) AS avg_quality
   FROM public.iot_sensor_data
  WHERE ("timestamp" >= (CURRENT_DATE - '90 days'::interval))
  GROUP BY device_id, sensor_type, (date("timestamp"));
-- Create index "idx_iot_sensor_daily_stats" to table: "iot_sensor_daily_stats"
CREATE INDEX "idx_iot_sensor_daily_stats" ON "public"."iot_sensor_daily_stats" ("device_id", "date" DESC);
-- Create "user_security_risk_scores" view
CREATE MATERIALIZED VIEW "public"."user_security_risk_scores" (
  "user_id",
  "email",
  "risk_score",
  "event_types",
  "high_severity_events",
  "last_security_event"
) AS SELECT u.id AS user_id,
    u.email,
    public.calculate_security_risk_score(u.id) AS risk_score,
    count(DISTINCT se.event_type) AS event_types,
    count(se.id) FILTER (WHERE (se.severity = ANY (ARRAY['critical'::public.event_severity, 'high'::public.event_severity]))) AS high_severity_events,
    max(se.created_at) AS last_security_event
   FROM (public.users u
     LEFT JOIN public.security_events se ON (((u.id = se.user_id) AND (se.created_at >= (CURRENT_TIMESTAMP - '30 days'::interval)))))
  GROUP BY u.id, u.email;
-- Create index "idx_user_security_risk_scores" to table: "user_security_risk_scores"
CREATE INDEX "idx_user_security_risk_scores" ON "public"."user_security_risk_scores" ("risk_score" DESC);
