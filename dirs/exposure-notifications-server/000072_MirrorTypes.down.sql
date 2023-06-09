-- Copyright 2021 the Exposure Notification Server authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

BEGIN;

ALTER SEQUENCE mirror_id_seq AS INT;
ALTER TABLE Mirror
  ALTER id TYPE INT,
  ALTER index_file TYPE VARCHAR(500),
  ALTER export_root TYPE VARCHAR(500),
  ALTER cloud_storage_bucket TYPE VARCHAR(200),
  ALTER filename_root TYPE VARCHAR(500),
  ALTER filename_rewrite TYPE VARCHAR(500);

END;
