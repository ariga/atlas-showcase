INSERT INTO identity_credential_types (id, name) SELECT '78c1b41d-8341-4507-aa60-aff1d4369670', 'password' WHERE NOT EXISTS ( SELECT * FROM identity_credential_types WHERE name = 'password');
