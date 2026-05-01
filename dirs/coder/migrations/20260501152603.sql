-- Modify "replicas" table
ALTER TABLE "replicas" ADD CONSTRAINT "replicas_database_latency_non_negative" CHECK (database_latency >= 0);
