UPDATE identity_recovery_tokens SET nid = (SELECT id FROM networks LIMIT 1);
