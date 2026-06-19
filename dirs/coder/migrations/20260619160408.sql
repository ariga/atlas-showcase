-- Modify "replicas" table
ALTER TABLE "replicas" ADD CONSTRAINT "replicas_stopped_at_not_before_started_at" CHECK ((stopped_at IS NULL) OR (stopped_at >= started_at));
