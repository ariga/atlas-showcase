-- Copyright 2020 the Exposure Notification Server authors
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

ALTER TABLE APIConfig ALTER COLUMN cts_profile_match DROP DEFAULT;
ALTER TABLE APIConfig ALTER COLUMN cts_profile_match SET NOT NULL;

ALTER TABLE APIConfig ALTER COLUMN basic_integrity DROP DEFAULT;
ALTER TABLE APIConfig ALTER COLUMN basic_integrity SET NOT NULL;

ALTER TABLE APIConfig ALTER COLUMN all_regions DROP DEFAULT;
ALTER TABLE APIConfig ALTER COLUMN all_regions SET NOT NULL;

END;
