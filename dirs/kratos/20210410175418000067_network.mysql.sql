ALTER TABLE `selfservice_verification_flows` ADD CONSTRAINT `selfservice_verification_flows_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
