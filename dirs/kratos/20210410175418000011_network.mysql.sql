ALTER TABLE `selfservice_settings_flows` ADD CONSTRAINT `selfservice_settings_flows_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
