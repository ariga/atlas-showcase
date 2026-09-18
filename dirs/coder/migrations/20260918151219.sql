-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_deleted_password_login_type_forbidden" CHECK ((deleted = false) OR (login_type <> 'password'::login_type));
