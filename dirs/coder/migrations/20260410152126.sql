-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_last_used_not_before_sentinel" CHECK (last_used >= '0001-01-01 00:00:00+00'::timestamp with time zone);
