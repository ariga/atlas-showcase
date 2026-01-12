-- Modify "api_keys" table
ALTER TABLE "api_keys" DROP COLUMN "last_used", ADD COLUMN "last_used_at" timestamptz NOT NULL;
