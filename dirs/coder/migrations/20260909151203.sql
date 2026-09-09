-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_basic_shape" CHECK (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'::text);
