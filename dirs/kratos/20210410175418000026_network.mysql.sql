ALTER TABLE `courier_messages` ADD CONSTRAINT `courier_messages_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
