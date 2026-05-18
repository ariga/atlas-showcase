-- Modify "provisioner_job_logs" table
ALTER TABLE "provisioner_job_logs" ADD CONSTRAINT "provisioner_job_logs_id_non_negative" CHECK (id >= 0);
