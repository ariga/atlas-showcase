-- create enum type "resource_conflict_severity"
CREATE TYPE "public"."resource_conflict_severity" AS ENUM ('none', 'minor', 'moderate', 'severe', 'critical');
