UPDATE identity_credential_identifiers SET nid = (SELECT id FROM networks LIMIT 1);
