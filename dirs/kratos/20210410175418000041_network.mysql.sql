ALTER TABLE `identity_credential_identifiers` ADD CONSTRAINT `identity_credential_identifiers_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
