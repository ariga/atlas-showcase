UPDATE identity_recovery_tokens SET identity_id=(SELECT identity_id FROM identity_recovery_addresses WHERE id=identity_recovery_address_id) WHERE identity_id = '' OR identity_id IS NULL;
