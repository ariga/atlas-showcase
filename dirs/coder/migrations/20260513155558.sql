-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_ip_address_not_unspecified_v6" CHECK (ip_address <> '::'::inet);
