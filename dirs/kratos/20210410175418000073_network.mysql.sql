UPDATE identity_verifiable_addresses SET nid = (SELECT id FROM networks LIMIT 1);
