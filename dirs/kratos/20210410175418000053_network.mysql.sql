ALTER TABLE `identity_recovery_addresses` ADD CONSTRAINT `identity_recovery_addresses_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
