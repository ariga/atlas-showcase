ALTER TABLE `identity_recovery_tokens` ADD CONSTRAINT `identity_recovery_tokens_identity_id_fk_idx` FOREIGN KEY (`identity_id`) REFERENCES `identities` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
