UPDATE identity_recovery_addresses SET nid = (SELECT id FROM networks LIMIT 1);
