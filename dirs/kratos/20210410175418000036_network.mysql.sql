ALTER TABLE `identity_credentials` ADD CONSTRAINT `identity_credentials_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
