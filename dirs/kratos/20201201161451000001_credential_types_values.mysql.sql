INSERT INTO identity_credential_types (id, name) SELECT '6fa5e2e0-bfce-4631-b62b-cf2b0252b289', 'oidc' WHERE NOT EXISTS ( SELECT * FROM identity_credential_types WHERE name = 'oidc');
