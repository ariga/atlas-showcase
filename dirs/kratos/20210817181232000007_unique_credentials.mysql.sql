CREATE UNIQUE INDEX `identity_credential_identifiers_identifier_nid_type_uq_idx` ON `identity_credential_identifiers` (`nid`, `identity_credential_type_id`, `identifier`);
