ALTER TABLE `continuity_containers` ADD CONSTRAINT `continuity_containers_nid_fk_idx` FOREIGN KEY (`nid`) REFERENCES `networks` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE;
