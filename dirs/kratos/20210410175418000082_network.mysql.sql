UPDATE identity_verification_tokens SET nid = (SELECT id FROM networks LIMIT 1);
