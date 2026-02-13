-- Modify "users" table
ALTER TABLE "users" DROP COLUMN "hashed_password", ADD COLUMN "password_hash" bytea NOT NULL;
