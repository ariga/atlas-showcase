-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_last_used_not_before_created_at" CHECK (last_used >= created_at);
