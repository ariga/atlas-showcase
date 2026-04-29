-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_expires_at_not_before_last_used" CHECK (expires_at >= last_used);
