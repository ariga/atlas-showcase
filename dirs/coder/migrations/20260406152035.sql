-- Modify "git_auth_links" table
ALTER TABLE "git_auth_links" ADD CONSTRAINT "git_auth_links_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
