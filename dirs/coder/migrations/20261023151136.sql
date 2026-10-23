-- Modify "replicas" table
ALTER TABLE "replicas" ADD CONSTRAINT "replicas_hostname_no_surrounding_whitespace" CHECK (hostname = btrim(hostname));
