-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_avatar_url_null_or_trimmed_non_empty" CHECK ((avatar_url IS NULL) OR ((avatar_url = btrim(avatar_url)) AND (length(btrim(avatar_url)) > 0)));
