ALTER TABLE `identity_recovery_tokens` ADD CONSTRAINT `identity_recovery_tokens_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
