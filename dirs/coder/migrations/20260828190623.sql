-- Create index "provisioner_jobs_organization_created_at_desc_idx" to table: "provisioner_jobs"
CREATE INDEX "provisioner_jobs_organization_created_at_desc_idx" ON "provisioner_jobs" ("organization_id", "created_at" DESC);
