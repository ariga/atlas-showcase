ALTER TABLE `identity_verifiable_addresses` ADD CONSTRAINT `identity_verifiable_addresses_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
