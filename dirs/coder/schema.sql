-- Add new schema named "public"
CREATE SCHEMA IF NOT EXISTS "public";
-- Set comment to schema: "public"
COMMENT ON SCHEMA "public" IS 'standard public schema';
-- Create enum type "workspace_agent_lifecycle_state"
CREATE TYPE "public"."workspace_agent_lifecycle_state" AS ENUM ('created', 'starting', 'start_timeout', 'start_error', 'ready', 'shutting_down', 'shutdown_timeout', 'shutdown_error', 'off');
-- Create enum type "workspace_agent_subsystem"
CREATE TYPE "public"."workspace_agent_subsystem" AS ENUM ('envbuilder', 'envbox', 'none');
-- Create enum type "provisioner_job_type"
CREATE TYPE "public"."provisioner_job_type" AS ENUM ('template_version_import', 'workspace_build', 'template_version_dry_run');
-- Create enum type "provisioner_storage_method"
CREATE TYPE "public"."provisioner_storage_method" AS ENUM ('file');
-- Create enum type "log_level"
CREATE TYPE "public"."log_level" AS ENUM ('trace', 'debug', 'info', 'warn', 'error');
-- Create enum type "log_source"
CREATE TYPE "public"."log_source" AS ENUM ('provisioner_daemon', 'provisioner');
-- Create enum type "parameter_type_system"
CREATE TYPE "public"."parameter_type_system" AS ENUM ('none', 'hcl');
-- Create enum type "parameter_source_scheme"
CREATE TYPE "public"."parameter_source_scheme" AS ENUM ('none', 'data');
-- Create enum type "parameter_destination_scheme"
CREATE TYPE "public"."parameter_destination_scheme" AS ENUM ('none', 'environment_variable', 'provisioner_variable');
-- Create "site_configs" table
CREATE TABLE "public"."site_configs" (
  "key" character varying(256) NOT NULL,
  "value" character varying(8192) NOT NULL,
  CONSTRAINT "site_configs_key_key" UNIQUE ("key")
);
-- Create enum type "resource_type"
CREATE TYPE "public"."resource_type" AS ENUM ('organization', 'template', 'template_version', 'user', 'workspace', 'git_ssh_key', 'api_key', 'group', 'workspace_build', 'license', 'workspace_proxy');
-- Create enum type "audit_action"
CREATE TYPE "public"."audit_action" AS ENUM ('create', 'write', 'delete', 'start', 'stop', 'login', 'logout', 'register');
-- Create enum type "parameter_scope"
CREATE TYPE "public"."parameter_scope" AS ENUM ('template', 'import_job', 'workspace');
-- Create enum type "build_reason"
CREATE TYPE "public"."build_reason" AS ENUM ('initiator', 'autostart', 'autostop');
-- Create enum type "login_type"
CREATE TYPE "public"."login_type" AS ENUM ('password', 'github', 'oidc', 'token');
-- Create enum type "api_key_scope"
CREATE TYPE "public"."api_key_scope" AS ENUM ('all', 'application_connect');
-- Create enum type "workspace_app_health"
CREATE TYPE "public"."workspace_app_health" AS ENUM ('disabled', 'initializing', 'healthy', 'unhealthy');
-- Create enum type "app_sharing_level"
CREATE TYPE "public"."app_sharing_level" AS ENUM ('owner', 'authenticated', 'public');
-- Create enum type "workspace_transition"
CREATE TYPE "public"."workspace_transition" AS ENUM ('start', 'stop', 'delete');
-- Create enum type "user_status"
CREATE TYPE "public"."user_status" AS ENUM ('active', 'suspended');
-- Create "users" table
CREATE TABLE "public"."users" (
  "id" uuid NOT NULL,
  "email" text NOT NULL,
  "username" text NOT NULL DEFAULT '',
  "hashed_password" bytea NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "status" "public"."user_status" NOT NULL DEFAULT 'active',
  "rbac_roles" text[] NOT NULL DEFAULT '{}',
  "login_type" "public"."login_type" NOT NULL DEFAULT 'password',
  "avatar_url" text NULL,
  "deleted" boolean NOT NULL DEFAULT false,
  "last_seen_at" timestamp NOT NULL DEFAULT '0001-01-01 00:00:00',
  PRIMARY KEY ("id"),
  CONSTRAINT "users_email_no_surrounding_whitespace" CHECK (email = btrim(email)),
  CONSTRAINT "users_email_not_empty" CHECK (length(btrim(email)) > 0),
  CONSTRAINT "users_email_lowercase_only" CHECK (email = lower(email)),
  CONSTRAINT "users_username_no_surrounding_whitespace" CHECK (username = btrim(username)),
  CONSTRAINT "users_username_not_empty" CHECK (length(btrim(username)) > 0),
  CONSTRAINT "users_username_lowercase_only" CHECK (username = lower(username)),
  CONSTRAINT "users_last_seen_at_not_before_sentinel" CHECK (last_seen_at >= TIMESTAMP '0001-01-01 00:00:00'),
  CONSTRAINT "users_last_seen_at_not_in_future" CHECK (last_seen_at <= (now() AT TIME ZONE 'UTC'))
);
-- Create index "idx_users_email" to table: "users"
CREATE UNIQUE INDEX "idx_users_email" ON "public"."users" ("email") WHERE (deleted = false);
-- Create index "idx_users_username" to table: "users"
CREATE UNIQUE INDEX "idx_users_username" ON "public"."users" ("username") WHERE (deleted = false);
-- NOTE: Destructive change applied: removed redundant index "users_email_lower_idx"
-- NOTE: Destructive change applied: removed duplicate index "users_username_lower_idx"
-- Create "insert_apikey_fail_if_user_deleted" function
CREATE FUNCTION "public"."insert_apikey_fail_if_user_deleted" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	IF (NEW.user_id IS NOT NULL) THEN
		IF (SELECT deleted FROM users WHERE id = NEW.user_id LIMIT 1) THEN
			RAISE EXCEPTION 'Cannot create API key for deleted user';
		END IF;
	END IF;
	RETURN NEW;
END;
$$;
-- Create "api_keys" table
CREATE TABLE "public"."api_keys" (
  "id" text NOT NULL,
  "hashed_secret" bytea NOT NULL,
  "user_id" uuid NOT NULL,
  "last_used" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "login_type" "public"."login_type" NOT NULL,
  "lifetime_seconds" bigint NOT NULL DEFAULT 86400,
  "ip_address" inet NOT NULL DEFAULT '0.0.0.0',
  "scope" "public"."api_key_scope" NOT NULL DEFAULT 'all',
  "token_name" text NOT NULL DEFAULT '',
  PRIMARY KEY ("id"),
  CONSTRAINT "api_keys_user_id_uuid_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "api_keys_lifetime_seconds_non_negative" CHECK (lifetime_seconds >= 0),
  CONSTRAINT "api_keys_expires_at_not_before_created_at" CHECK (expires_at >= created_at)
);
-- Create index "idx_api_key_name" to table: "api_keys"
CREATE UNIQUE INDEX "idx_api_key_name" ON "public"."api_keys" ("user_id", "token_name") WHERE (login_type = 'token'::public.login_type);
-- Create index "idx_api_keys_user" to table: "api_keys"
CREATE INDEX "idx_api_keys_user" ON "public"."api_keys" ("user_id");
-- Set comment to column: "hashed_secret" on table: "api_keys"
COMMENT ON COLUMN "public"."api_keys"."hashed_secret" IS 'hashed_secret contains a SHA256 hash of the key secret. This is considered a secret and MUST NOT be returned from the API as it is used for API key encryption in app proxying code.';
-- Create trigger "trigger_insert_apikeys"
CREATE TRIGGER "trigger_insert_apikeys" BEFORE INSERT ON "public"."api_keys" FOR EACH ROW EXECUTE FUNCTION "public"."insert_apikey_fail_if_user_deleted"();
-- Create "audit_logs" table
CREATE TABLE "public"."audit_logs" (
  "id" uuid NOT NULL,
  "time" timestamptz NOT NULL,
  "user_id" uuid NOT NULL,
  "organization_id" uuid NOT NULL,
  "ip" inet NULL,
  "user_agent" character varying(256) NULL,
  "resource_type" "public"."resource_type" NOT NULL,
  "resource_id" uuid NOT NULL,
  "resource_target" text NOT NULL,
  "action" "public"."audit_action" NOT NULL,
  "diff" jsonb NOT NULL,
  "status_code" integer NOT NULL,
  "additional_fields" jsonb NOT NULL,
  "request_id" uuid NOT NULL,
  "resource_icon" text NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "idx_audit_log_organization_id" to table: "audit_logs"
CREATE INDEX "idx_audit_log_organization_id" ON "public"."audit_logs" ("organization_id");
-- Create index "idx_audit_log_resource_id" to table: "audit_logs"
CREATE INDEX "idx_audit_log_resource_id" ON "public"."audit_logs" ("resource_id");
-- Create index "idx_audit_log_user_id" to table: "audit_logs"
CREATE INDEX "idx_audit_log_user_id" ON "public"."audit_logs" ("user_id");
-- Create index "idx_audit_logs_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_time_desc" ON "public"."audit_logs" ("time" DESC);
-- Create index "idx_audit_logs_org_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_org_time_desc" ON "public"."audit_logs" ("organization_id", "time" DESC);
-- Create index "idx_audit_logs_user_time_desc" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_user_time_desc" ON "public"."audit_logs" ("user_id", "time" DESC);
-- Create index "idx_audit_logs_request_id" to table: "audit_logs"
CREATE INDEX "idx_audit_logs_request_id" ON "public"."audit_logs" ("request_id") WHERE (request_id IS NOT NULL);
-- Create "files" table
CREATE TABLE "public"."files" (
  "hash" character varying(64) NOT NULL,
  "created_at" timestamptz NOT NULL,
  "created_by" uuid NOT NULL,
  "mimetype" character varying(64) NOT NULL,
  "data" bytea NOT NULL,
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  PRIMARY KEY ("id"),
  CONSTRAINT "files_hash_created_by_key" UNIQUE ("hash", "created_by")
);
-- Create "git_auth_links" table
CREATE TABLE "public"."git_auth_links" (
  "provider_id" text NOT NULL,
  "user_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "oauth_access_token" text NOT NULL,
  "oauth_refresh_token" text NOT NULL,
  "oauth_expiry" timestamptz NOT NULL,
  CONSTRAINT "git_auth_links_provider_id_user_id_key" UNIQUE ("provider_id", "user_id")
);
-- Create "replicas" table
CREATE TABLE "public"."replicas" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "started_at" timestamptz NOT NULL,
  "stopped_at" timestamptz NULL,
  "updated_at" timestamptz NOT NULL,
  "hostname" text NOT NULL,
  "region_id" integer NOT NULL,
  "relay_address" text NOT NULL,
  "database_latency" integer NOT NULL,
  "version" text NOT NULL,
  "error" text NOT NULL DEFAULT ''
);
-- Create enum type "provisioner_type"
CREATE TYPE "public"."provisioner_type" AS ENUM ('echo', 'terraform');
-- Create "licenses" table
CREATE TABLE "public"."licenses" (
  "id" serial NOT NULL,
  "uploaded_at" timestamptz NOT NULL,
  "jwt" text NOT NULL,
  "exp" timestamptz NOT NULL,
  "uuid" uuid NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "licenses_jwt_key" UNIQUE ("jwt")
);
-- Set comment to column: "exp" on table: "licenses"
COMMENT ON COLUMN "public"."licenses"."exp" IS 'exp tracks the claim of the same name in the JWT, and we include it here so that we can easily query for licenses that have not yet expired.';
-- Create "delete_deleted_user_api_keys" function
CREATE FUNCTION "public"."delete_deleted_user_api_keys" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	IF (NEW.deleted) THEN
		DELETE FROM api_keys
		WHERE user_id = OLD.id;
	END IF;
	RETURN NEW;
END;
$$;
-- Create trigger "trigger_update_users"
CREATE TRIGGER "trigger_update_users" AFTER INSERT OR UPDATE ON "public"."users" FOR EACH ROW WHEN (new.deleted = true) EXECUTE FUNCTION "public"."delete_deleted_user_api_keys"();
-- Create "workspace_proxies" table
CREATE TABLE "public"."workspace_proxies" (
  "id" uuid NOT NULL,
  "name" text NOT NULL,
  "display_name" text NOT NULL,
  "icon" text NOT NULL,
  "url" text NOT NULL,
  "wildcard_hostname" text NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "deleted" boolean NOT NULL,
  "token_hashed_secret" bytea NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "workspace_proxies_lower_name_idx" to table: "workspace_proxies"
CREATE UNIQUE INDEX "workspace_proxies_lower_name_idx" ON "public"."workspace_proxies" ((lower(name))) WHERE (deleted = false);
-- Set comment to column: "icon" on table: "workspace_proxies"
COMMENT ON COLUMN "public"."workspace_proxies"."icon" IS 'Expects an emoji character. (/emojis/1f1fa-1f1f8.png)';
-- Set comment to column: "url" on table: "workspace_proxies"
COMMENT ON COLUMN "public"."workspace_proxies"."url" IS 'Full url including scheme of the proxy api url: https://us.example.com';
-- Set comment to column: "wildcard_hostname" on table: "workspace_proxies"
COMMENT ON COLUMN "public"."workspace_proxies"."wildcard_hostname" IS 'Hostname with the wildcard for subdomain based app hosting: *.us.example.com';
-- Set comment to column: "deleted" on table: "workspace_proxies"
COMMENT ON COLUMN "public"."workspace_proxies"."deleted" IS 'Boolean indicator of a deleted workspace proxy. Proxies are soft-deleted.';
-- Set comment to column: "token_hashed_secret" on table: "workspace_proxies"
COMMENT ON COLUMN "public"."workspace_proxies"."token_hashed_secret" IS 'Hashed secret is used to authenticate the workspace proxy using a session token.';
-- Create "parameter_values" table
CREATE TABLE "public"."parameter_values" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "scope" "public"."parameter_scope" NOT NULL,
  "scope_id" uuid NOT NULL,
  "name" character varying(64) NOT NULL,
  "source_scheme" "public"."parameter_source_scheme" NOT NULL,
  "source_value" text NOT NULL,
  "destination_scheme" "public"."parameter_destination_scheme" NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "parameter_values_scope_id_name_key" UNIQUE ("scope_id", "name")
);
-- Create "provisioner_daemons" table
CREATE TABLE "public"."provisioner_daemons" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NULL,
  "name" character varying(64) NOT NULL,
  "provisioners" "public"."provisioner_type"[] NOT NULL,
  "replica_id" uuid NULL,
  "tags" jsonb NOT NULL DEFAULT '{}',
  PRIMARY KEY ("id"),
  CONSTRAINT "provisioner_daemons_name_key" UNIQUE ("name")
);
-- Create "workspace_agent_stats" table
CREATE TABLE "public"."workspace_agent_stats" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "user_id" uuid NOT NULL,
  "agent_id" uuid NOT NULL,
  "workspace_id" uuid NOT NULL,
  "template_id" uuid NOT NULL,
  "connections_by_proto" jsonb NOT NULL DEFAULT '{}',
  "connection_count" bigint NOT NULL DEFAULT 0,
  "rx_packets" bigint NOT NULL DEFAULT 0,
  "rx_bytes" bigint NOT NULL DEFAULT 0,
  "tx_packets" bigint NOT NULL DEFAULT 0,
  "tx_bytes" bigint NOT NULL DEFAULT 0,
  "connection_median_latency_ms" double precision NOT NULL DEFAULT -1,
  "session_count_vscode" bigint NOT NULL DEFAULT 0,
  "session_count_jetbrains" bigint NOT NULL DEFAULT 0,
  "session_count_reconnecting_pty" bigint NOT NULL DEFAULT 0,
  "session_count_ssh" bigint NOT NULL DEFAULT 0,
  CONSTRAINT "agent_stats_pkey" PRIMARY KEY ("id")
);
-- Create index "idx_agent_stats_created_at" to table: "workspace_agent_stats"
CREATE INDEX "idx_agent_stats_created_at" ON "public"."workspace_agent_stats" ("created_at");
-- Create index "idx_agent_stats_user_id" to table: "workspace_agent_stats"
CREATE INDEX "idx_agent_stats_user_id" ON "public"."workspace_agent_stats" ("user_id");
-- Create "gitsshkeys" table
CREATE TABLE "public"."gitsshkeys" (
  "user_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "private_key" text NOT NULL,
  "public_key" text NOT NULL,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "gitsshkeys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "organizations" table
CREATE TABLE "public"."organizations" (
  "id" uuid NOT NULL,
  "name" text NOT NULL,
  "description" text NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "idx_organization_name" to table: "organizations"
CREATE UNIQUE INDEX "idx_organization_name" ON "public"."organizations" ("name");
-- Create index "idx_organization_name_lower" to table: "organizations"
CREATE UNIQUE INDEX "idx_organization_name_lower" ON "public"."organizations" ((lower(name)));
-- Create "groups" table
CREATE TABLE "public"."groups" (
  "id" uuid NOT NULL,
  "name" text NOT NULL,
  "organization_id" uuid NOT NULL,
  "avatar_url" text NOT NULL DEFAULT '',
  "quota_allowance" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "groups_name_organization_id_key" UNIQUE ("name", "organization_id"),
  CONSTRAINT "groups_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create "group_members" table
CREATE TABLE "public"."group_members" (
  "user_id" uuid NOT NULL,
  "group_id" uuid NOT NULL,
  CONSTRAINT "group_members_user_id_group_id_key" UNIQUE ("user_id", "group_id"),
  CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create "organization_members" table
CREATE TABLE "public"."organization_members" (
  "user_id" uuid NOT NULL,
  "organization_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "roles" text[] NOT NULL DEFAULT '{organization-member}',
  PRIMARY KEY ("organization_id", "user_id"),
  CONSTRAINT "organization_members_organization_id_uuid_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "organization_members_user_id_uuid_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "idx_organization_member_organization_id_uuid" to table: "organization_members"
CREATE INDEX "idx_organization_member_organization_id_uuid" ON "public"."organization_members" ("organization_id");
-- Create index "idx_organization_member_user_id_uuid" to table: "organization_members"
CREATE INDEX "idx_organization_member_user_id_uuid" ON "public"."organization_members" ("user_id");
-- Create "provisioner_jobs" table
CREATE TABLE "public"."provisioner_jobs" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "started_at" timestamptz NULL,
  "canceled_at" timestamptz NULL,
  "completed_at" timestamptz NULL,
  "error" text NULL,
  "organization_id" uuid NOT NULL,
  "initiator_id" uuid NOT NULL,
  "provisioner" "public"."provisioner_type" NOT NULL,
  "storage_method" "public"."provisioner_storage_method" NOT NULL,
  "type" "public"."provisioner_job_type" NOT NULL,
  "input" jsonb NOT NULL,
  "worker_id" uuid NULL,
  "file_id" uuid NOT NULL,
  "tags" jsonb NOT NULL DEFAULT '{"scope": "organization"}',
  "error_code" text NULL,
  "trace_metadata" jsonb NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "provisioner_jobs_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "provisioner_jobs_started_at_idx" to table: "provisioner_jobs"
CREATE INDEX "provisioner_jobs_started_at_idx" ON "public"."provisioner_jobs" ("started_at") WHERE (started_at IS NULL);
-- Create "parameter_schemas" table
CREATE TABLE "public"."parameter_schemas" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "job_id" uuid NOT NULL,
  "name" character varying(64) NOT NULL,
  "description" character varying(8192) NOT NULL DEFAULT '',
  "default_source_scheme" "public"."parameter_source_scheme" NOT NULL,
  "default_source_value" text NOT NULL,
  "allow_override_source" boolean NOT NULL,
  "default_destination_scheme" "public"."parameter_destination_scheme" NOT NULL,
  "allow_override_destination" boolean NOT NULL,
  "default_refresh" text NOT NULL,
  "redisplay_value" boolean NOT NULL,
  "validation_error" character varying(256) NOT NULL,
  "validation_condition" character varying(512) NOT NULL,
  "validation_type_system" "public"."parameter_type_system" NOT NULL,
  "validation_value_type" character varying(64) NOT NULL,
  "index" integer NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "parameter_schemas_job_id_name_key" UNIQUE ("job_id", "name"),
  CONSTRAINT "parameter_schemas_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."provisioner_jobs" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create "provisioner_job_logs" table
CREATE TABLE "public"."provisioner_job_logs" (
  "job_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "source" "public"."log_source" NOT NULL,
  "level" "public"."log_level" NOT NULL,
  "stage" character varying(128) NOT NULL,
  "output" character varying(1024) NOT NULL,
  "id" bigserial NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "provisioner_job_logs_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."provisioner_jobs" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "provisioner_job_logs_id_job_id_idx" to table: "provisioner_job_logs"
CREATE INDEX "provisioner_job_logs_id_job_id_idx" ON "public"."provisioner_job_logs" ("job_id", "id");
-- Create "templates" table
CREATE TABLE "public"."templates" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "organization_id" uuid NOT NULL,
  "deleted" boolean NOT NULL DEFAULT false,
  "name" character varying(64) NOT NULL,
  "provisioner" "public"."provisioner_type" NOT NULL,
  "active_version_id" uuid NOT NULL,
  "description" character varying(128) NOT NULL DEFAULT '',
  "default_ttl" bigint NOT NULL DEFAULT 604800000000000,
  "created_by" uuid NOT NULL,
  "icon" character varying(256) NOT NULL DEFAULT '',
  "user_acl" jsonb NOT NULL DEFAULT '{}',
  "group_acl" jsonb NOT NULL DEFAULT '{}',
  "display_name" character varying(64) NOT NULL DEFAULT '',
  "allow_user_cancel_workspace_jobs" boolean NOT NULL DEFAULT true,
  "max_ttl" bigint NOT NULL DEFAULT 0,
  "allow_user_autostart" boolean NOT NULL DEFAULT true,
  "allow_user_autostop" boolean NOT NULL DEFAULT true,
  "failure_ttl" bigint NOT NULL DEFAULT 0,
  "inactivity_ttl" bigint NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "templates_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "templates_organization_id_name_idx" to table: "templates"
CREATE UNIQUE INDEX "templates_organization_id_name_idx" ON "public"."templates" ("organization_id", (lower((name)::text))) WHERE (deleted = false);
-- Set comment to column: "default_ttl" on table: "templates"
COMMENT ON COLUMN "public"."templates"."default_ttl" IS 'The default duration for autostop for workspaces created from this template.';
-- Set comment to column: "display_name" on table: "templates"
COMMENT ON COLUMN "public"."templates"."display_name" IS 'Display name is a custom, human-friendly template name that user can set.';
-- Set comment to column: "allow_user_cancel_workspace_jobs" on table: "templates"
COMMENT ON COLUMN "public"."templates"."allow_user_cancel_workspace_jobs" IS 'Allow users to cancel in-progress workspace jobs.';
-- Set comment to column: "allow_user_autostart" on table: "templates"
COMMENT ON COLUMN "public"."templates"."allow_user_autostart" IS 'Allow users to specify an autostart schedule for workspaces (enterprise).';
-- Set comment to column: "allow_user_autostop" on table: "templates"
COMMENT ON COLUMN "public"."templates"."allow_user_autostop" IS 'Allow users to specify custom autostop values for workspaces (enterprise).';
-- Create "template_versions" table
CREATE TABLE "public"."template_versions" (
  "id" uuid NOT NULL,
  "template_id" uuid NULL,
  "organization_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "name" character varying(64) NOT NULL,
  "readme" character varying(1048576) NOT NULL,
  "job_id" uuid NOT NULL,
  "created_by" uuid NOT NULL,
  "git_auth_providers" text[] NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "template_versions_template_id_name_key" UNIQUE ("template_id", "name"),
  CONSTRAINT "template_versions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "template_versions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "template_versions_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."templates" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Set comment to column: "git_auth_providers" on table: "template_versions"
COMMENT ON COLUMN "public"."template_versions"."git_auth_providers" IS 'IDs of Git auth providers for a specific template version';
-- Create "template_version_parameters" table
CREATE TABLE "public"."template_version_parameters" (
  "template_version_id" uuid NOT NULL,
  "name" text NOT NULL,
  "description" text NOT NULL,
  "type" text NOT NULL,
  "mutable" boolean NOT NULL,
  "default_value" text NOT NULL,
  "icon" text NOT NULL,
  "options" jsonb NOT NULL DEFAULT '[]',
  "validation_regex" text NOT NULL,
  "validation_min" integer NULL,
  "validation_max" integer NULL,
  "validation_error" text NOT NULL DEFAULT '',
  "validation_monotonic" text NOT NULL DEFAULT '',
  "required" boolean NOT NULL DEFAULT true,
  "legacy_variable_name" text NOT NULL DEFAULT '',
  "display_name" text NOT NULL DEFAULT '',
  CONSTRAINT "template_version_parameters_template_version_id_name_key" UNIQUE ("template_version_id", "name"),
  CONSTRAINT "template_version_parameters_template_version_id_fkey" FOREIGN KEY ("template_version_id") REFERENCES "public"."template_versions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "validation_monotonic_order" CHECK (validation_monotonic = ANY (ARRAY['increasing'::text, 'decreasing'::text, ''::text]))
);
-- Set comment to column: "name" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."name" IS 'Parameter name';
-- Set comment to column: "description" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."description" IS 'Parameter description';
-- Set comment to column: "type" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."type" IS 'Parameter type';
-- Set comment to column: "mutable" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."mutable" IS 'Is parameter mutable?';
-- Set comment to column: "default_value" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."default_value" IS 'Default value';
-- Set comment to column: "icon" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."icon" IS 'Icon';
-- Set comment to column: "options" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."options" IS 'Additional options';
-- Set comment to column: "validation_regex" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."validation_regex" IS 'Validation: regex pattern';
-- Set comment to column: "validation_min" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."validation_min" IS 'Validation: minimum length of value';
-- Set comment to column: "validation_max" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."validation_max" IS 'Validation: maximum length of value';
-- Set comment to column: "validation_error" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."validation_error" IS 'Validation: error displayed when the regex does not match.';
-- Set comment to column: "validation_monotonic" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."validation_monotonic" IS 'Validation: consecutive values preserve the monotonic order';
-- Set comment to column: "required" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."required" IS 'Is parameter required?';
-- Set comment to column: "legacy_variable_name" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."legacy_variable_name" IS 'Name of the legacy variable for migration purposes';
-- Set comment to column: "display_name" on table: "template_version_parameters"
COMMENT ON COLUMN "public"."template_version_parameters"."display_name" IS 'Display name of the rich parameter';
-- Create "template_version_variables" table
CREATE TABLE "public"."template_version_variables" (
  "template_version_id" uuid NOT NULL,
  "name" text NOT NULL,
  "description" text NOT NULL,
  "type" text NOT NULL,
  "value" text NOT NULL,
  "default_value" text NOT NULL,
  "required" boolean NOT NULL,
  "sensitive" boolean NOT NULL,
  CONSTRAINT "template_version_variables_template_version_id_name_key" UNIQUE ("template_version_id", "name"),
  CONSTRAINT "template_version_variables_template_version_id_fkey" FOREIGN KEY ("template_version_id") REFERENCES "public"."template_versions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Set comment to column: "name" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."name" IS 'Variable name';
-- Set comment to column: "description" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."description" IS 'Variable description';
-- Set comment to column: "type" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."type" IS 'Variable type';
-- Set comment to column: "value" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."value" IS 'Variable value';
-- Set comment to column: "default_value" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."default_value" IS 'Variable default value';
-- Set comment to column: "required" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."required" IS 'Required variables needs a default value or a value provided by template admin';
-- Set comment to column: "sensitive" on table: "template_version_variables"
COMMENT ON COLUMN "public"."template_version_variables"."sensitive" IS 'Sensitive variables have their values redacted in logs or site UI';
-- Create "user_links" table
CREATE TABLE "public"."user_links" (
  "user_id" uuid NOT NULL,
  "login_type" "public"."login_type" NOT NULL,
  "linked_id" text NOT NULL DEFAULT '',
  "oauth_access_token" text NOT NULL DEFAULT '',
  "oauth_refresh_token" text NOT NULL DEFAULT '',
  "oauth_expiry" timestamptz NOT NULL DEFAULT '0001-01-01 00:00:00+00',
  PRIMARY KEY ("user_id", "login_type"),
  CONSTRAINT "user_links_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create "workspace_resources" table
CREATE TABLE "public"."workspace_resources" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "job_id" uuid NOT NULL,
  "transition" "public"."workspace_transition" NOT NULL,
  "type" character varying(192) NOT NULL,
  "name" character varying(64) NOT NULL,
  "hide" boolean NOT NULL DEFAULT false,
  "icon" character varying(256) NOT NULL DEFAULT '',
  "instance_type" character varying(256) NULL,
  "daily_cost" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_resources_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."provisioner_jobs" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "workspace_resources_daily_cost_non_negative" CHECK (daily_cost >= 0)
);
-- Create index "workspace_resources_job_id_idx" to table: "workspace_resources"
CREATE INDEX "workspace_resources_job_id_idx" ON "public"."workspace_resources" ("job_id");
-- Create "workspace_agents" table
CREATE TABLE "public"."workspace_agents" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "name" character varying(64) NOT NULL,
  "first_connected_at" timestamptz NULL,
  "last_connected_at" timestamptz NULL,
  "disconnected_at" timestamptz NULL,
  "resource_id" uuid NOT NULL,
  "auth_token" uuid NOT NULL,
  "auth_instance_id" character varying NULL,
  "architecture" character varying(64) NOT NULL,
  "environment_variables" jsonb NULL,
  "operating_system" character varying(64) NOT NULL,
  "startup_script" character varying(65534) NULL,
  "instance_metadata" jsonb NULL,
  "resource_metadata" jsonb NULL,
  "directory" character varying(4096) NOT NULL DEFAULT '',
  "version" text NOT NULL DEFAULT '',
  "last_connected_replica_id" uuid NULL,
  "connection_timeout_seconds" integer NOT NULL DEFAULT 0,
  "troubleshooting_url" text NOT NULL DEFAULT '',
  "motd_file" text NOT NULL DEFAULT '',
  "lifecycle_state" "public"."workspace_agent_lifecycle_state" NOT NULL DEFAULT 'created',
  "login_before_ready" boolean NOT NULL DEFAULT true,
  "startup_script_timeout_seconds" integer NOT NULL DEFAULT 0,
  "expanded_directory" character varying(4096) NOT NULL DEFAULT '',
  "shutdown_script" character varying(65534) NULL,
  "shutdown_script_timeout_seconds" integer NOT NULL DEFAULT 0,
  "startup_logs_length" integer NOT NULL DEFAULT 0,
  "startup_logs_overflowed" boolean NOT NULL DEFAULT false,
  "subsystem" "public"."workspace_agent_subsystem" NOT NULL DEFAULT 'none',
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_agents_resource_id_fkey" FOREIGN KEY ("resource_id") REFERENCES "public"."workspace_resources" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "max_startup_logs_length" CHECK (startup_logs_length <= 1048576),
  CONSTRAINT "workspace_agents_connection_timeout_seconds_non_negative" CHECK (connection_timeout_seconds >= 0)
);
-- Create index "workspace_agents_auth_token_idx" to table: "workspace_agents"
CREATE INDEX "workspace_agents_auth_token_idx" ON "public"."workspace_agents" ("auth_token");
-- Create index "workspace_agents_resource_id_idx" to table: "workspace_agents"
CREATE INDEX "workspace_agents_resource_id_idx" ON "public"."workspace_agents" ("resource_id");
-- Set comment to column: "version" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."version" IS 'Version tracks the version of the currently running workspace agent. Workspace agents register their version upon start.';
-- Set comment to column: "connection_timeout_seconds" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."connection_timeout_seconds" IS 'Connection timeout in seconds, 0 means disabled.';
-- Set comment to column: "troubleshooting_url" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."troubleshooting_url" IS 'URL for troubleshooting the agent.';
-- Set comment to column: "motd_file" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."motd_file" IS 'Path to file inside workspace containing the message of the day (MOTD) to show to the user when logging in via SSH.';
-- Set comment to column: "lifecycle_state" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."lifecycle_state" IS 'The current lifecycle state reported by the workspace agent.';
-- Set comment to column: "login_before_ready" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."login_before_ready" IS 'If true, the agent will not prevent login before it is ready (e.g. startup script is still executing).';
-- Set comment to column: "startup_script_timeout_seconds" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."startup_script_timeout_seconds" IS 'The number of seconds to wait for the startup script to complete. If the script does not complete within this time, the agent lifecycle will be marked as start_timeout.';
-- Set comment to column: "expanded_directory" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."expanded_directory" IS 'The resolved path of a user-specified directory. e.g. ~/coder -> /home/coder/coder';
-- Set comment to column: "shutdown_script" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."shutdown_script" IS 'Script that is executed before the agent is stopped.';
-- Set comment to column: "shutdown_script_timeout_seconds" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."shutdown_script_timeout_seconds" IS 'The number of seconds to wait for the shutdown script to complete within this time, the agent lifecycle will be marked as shutdown_timeout.';
-- Set comment to column: "startup_logs_length" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."startup_logs_length" IS 'Total length of startup logs';
-- Set comment to column: "startup_logs_overflowed" on table: "workspace_agents"
COMMENT ON COLUMN "public"."workspace_agents"."startup_logs_overflowed" IS 'Whether the startup logs overflowed in length';
-- Create "workspace_agent_metadata" table
CREATE UNLOGGED TABLE "public"."workspace_agent_metadata" (
  "workspace_agent_id" uuid NOT NULL,
  "display_name" character varying(127) NOT NULL,
  "key" character varying(127) NOT NULL,
  "script" character varying(65535) NOT NULL,
  "value" character varying(65535) NOT NULL DEFAULT '',
  "error" character varying(65535) NOT NULL DEFAULT '',
  "timeout" bigint NOT NULL,
  "interval" bigint NOT NULL,
  "collected_at" timestamptz NOT NULL DEFAULT '0001-01-01 00:00:00+00',
  PRIMARY KEY ("workspace_agent_id", "key"),
  CONSTRAINT "workspace_agent_metadata_workspace_agent_id_fkey" FOREIGN KEY ("workspace_agent_id") REFERENCES "public"."workspace_agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create "workspace_agent_startup_logs" table
CREATE TABLE "public"."workspace_agent_startup_logs" (
  "agent_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "output" character varying(1024) NOT NULL,
  "id" bigserial NOT NULL,
  "level" "public"."log_level" NOT NULL DEFAULT 'info',
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_agent_startup_logs_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "public"."workspace_agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "workspace_agent_startup_logs_id_agent_id_idx" to table: "workspace_agent_startup_logs"
CREATE INDEX "workspace_agent_startup_logs_id_agent_id_idx" ON "public"."workspace_agent_startup_logs" ("agent_id", "id");
-- Create "workspace_apps" table
CREATE TABLE "public"."workspace_apps" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "agent_id" uuid NOT NULL,
  "display_name" character varying(64) NOT NULL,
  "icon" character varying(256) NOT NULL,
  "command" character varying(65534) NULL,
  "url" character varying(65534) NULL,
  "healthcheck_url" text NOT NULL DEFAULT '',
  "healthcheck_interval" integer NOT NULL DEFAULT 0,
  "healthcheck_threshold" integer NOT NULL DEFAULT 0,
  "health" "public"."workspace_app_health" NOT NULL DEFAULT 'disabled',
  "subdomain" boolean NOT NULL DEFAULT false,
  "sharing_level" "public"."app_sharing_level" NOT NULL DEFAULT 'owner',
  "slug" text NOT NULL,
  "external" boolean NOT NULL DEFAULT false,
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_apps_agent_id_slug_idx" UNIQUE ("agent_id", "slug"),
  CONSTRAINT "workspace_apps_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "public"."workspace_agents" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "workspace_apps_healthcheck_interval_non_negative" CHECK (healthcheck_interval >= 0)
);
-- Create "workspaces" table
CREATE TABLE "public"."workspaces" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "owner_id" uuid NOT NULL,
  "organization_id" uuid NOT NULL,
  "template_id" uuid NOT NULL,
  "deleted" boolean NOT NULL DEFAULT false,
  "name" character varying(64) NOT NULL,
  "autostart_schedule" text NULL,
  "ttl" bigint NULL,
  "last_used_at" timestamp NOT NULL DEFAULT '0001-01-01 00:00:00',
  PRIMARY KEY ("id"),
  CONSTRAINT "workspaces_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "workspaces_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "workspaces_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."templates" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT "workspaces_ttl_non_negative" CHECK (ttl IS NULL OR ttl >= 0),
  CONSTRAINT "workspaces_last_used_at_not_before_sentinel" CHECK (last_used_at >= TIMESTAMP '0001-01-01 00:00:00')
);
-- Create index "workspaces_owner_id_lower_idx" to table: "workspaces"
CREATE UNIQUE INDEX "workspaces_owner_id_lower_idx" ON "public"."workspaces" ("owner_id", (lower((name)::text))) WHERE (deleted = false);
-- Create "workspace_builds" table
CREATE TABLE "public"."workspace_builds" (
  "id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "workspace_id" uuid NOT NULL,
  "template_version_id" uuid NOT NULL,
  "build_number" integer NOT NULL,
  "transition" "public"."workspace_transition" NOT NULL,
  "initiator_id" uuid NOT NULL,
  "provisioner_state" bytea NULL,
  "job_id" uuid NOT NULL,
  "deadline" timestamptz NOT NULL DEFAULT '0001-01-01 00:00:00+00',
  "reason" "public"."build_reason" NOT NULL DEFAULT 'initiator',
  "daily_cost" integer NOT NULL DEFAULT 0,
  "max_deadline" timestamptz NOT NULL DEFAULT '0001-01-01 00:00:00+00',
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_builds_job_id_key" UNIQUE ("job_id"),
  CONSTRAINT "workspace_builds_workspace_id_build_number_key" UNIQUE ("workspace_id", "build_number"),
  CONSTRAINT "workspace_builds_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."provisioner_jobs" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "workspace_builds_template_version_id_fkey" FOREIGN KEY ("template_version_id") REFERENCES "public"."template_versions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "workspace_builds_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "public"."workspaces" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Create index "workspace_builds_workspace_id_created_at_desc_idx" to table: "workspace_builds"
CREATE INDEX "workspace_builds_workspace_id_created_at_desc_idx" ON "public"."workspace_builds" ("workspace_id", "created_at" DESC);
-- Create "workspace_build_parameters" table
CREATE TABLE "public"."workspace_build_parameters" (
  "workspace_build_id" uuid NOT NULL,
  "name" text NOT NULL,
  "value" text NOT NULL,
  CONSTRAINT "workspace_build_parameters_workspace_build_id_name_key" UNIQUE ("workspace_build_id", "name"),
  CONSTRAINT "workspace_build_parameters_workspace_build_id_fkey" FOREIGN KEY ("workspace_build_id") REFERENCES "public"."workspace_builds" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);
-- Set comment to column: "name" on table: "workspace_build_parameters"
COMMENT ON COLUMN "public"."workspace_build_parameters"."name" IS 'Parameter name';
-- Set comment to column: "value" on table: "workspace_build_parameters"
COMMENT ON COLUMN "public"."workspace_build_parameters"."value" IS 'Parameter value';
-- Create "workspace_resource_metadata" table
CREATE TABLE "public"."workspace_resource_metadata" (
  "workspace_resource_id" uuid NOT NULL,
  "key" character varying(1024) NOT NULL,
  "value" character varying(65536) NULL,
  "sensitive" boolean NOT NULL,
  "id" bigserial NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "workspace_resource_metadata_name" UNIQUE ("workspace_resource_id", "key"),
  CONSTRAINT "workspace_resource_metadata_workspace_resource_id_fkey" FOREIGN KEY ("workspace_resource_id") REFERENCES "public"."workspace_resources" ("id") ON UPDATE NO ACTION ON DELETE CASCADE
);