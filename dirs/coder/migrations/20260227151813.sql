-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_expires_at_not_before_created_at" CHECK (expires_at >= created_at);
