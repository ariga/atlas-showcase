-- Create index "workspace_apps_slug_external_idx" to table: "workspace_apps"
CREATE INDEX "workspace_apps_slug_external_idx" ON "workspace_apps" ("slug", "external");
