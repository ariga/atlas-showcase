ALTER TABLE `selfservice_recovery_flows` ADD CONSTRAINT `selfservice_recovery_flows_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
