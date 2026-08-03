-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_last_used_not_in_future_utc" CHECK (last_used <= (now() AT TIME ZONE 'UTC'::text));
