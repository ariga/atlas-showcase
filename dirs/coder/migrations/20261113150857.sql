-- Create index "provisioner_jobs_worker_id_idx" to table: "provisioner_jobs"
CREATE INDEX "provisioner_jobs_worker_id_idx" ON "provisioner_jobs" ("worker_id") WHERE (worker_id IS NOT NULL);
