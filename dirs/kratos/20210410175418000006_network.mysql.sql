ALTER TABLE `selfservice_registration_flows` ADD CONSTRAINT `selfservice_registration_flows_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
