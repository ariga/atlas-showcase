-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_expires_at_not_in_past_utc" CHECK (expires_at >= (now() AT TIME ZONE 'UTC'::text));
