ALTER TABLE `identity_verification_tokens` ADD CONSTRAINT `identity_verification_tokens_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
